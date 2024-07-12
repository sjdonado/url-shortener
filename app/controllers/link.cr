require "uuid"
require "user_agent_parser"

UserAgent.load_regexes(File.read("data/regexes.yaml"))

require "../lib/controller.cr"

module App::Controllers::Link
  class Create < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      user = env.get("user").as(User)
      body = parse_body(env, ["url"])
      url = body["url"].to_s

      query = Database::Query.where(url: url, user_id: user.id.as(String)).limit(1)
      existing_links = Database.all(Link, query)
      existing_link = existing_links.empty? ? nil : existing_links.first
      if existing_link
        response = {"data" => App::Serializers::Link.new(existing_link)}
        return response.to_json
      end

      link = Link.new
      link.id = UUID.v4.to_s
      link.url = url
      link.user = user

      loop do
        slug = Random::Secure.urlsafe_base64(4).gsub(/[^a-zA-Z0-9]/, "")
        if !Database.get_by(Link, slug: slug)
          link.slug = slug
          break
        end
      end

      changeset = Database.insert(link)
      if !changeset.valid?
        raise App::UnprocessableEntityException.new(env, map_changeset_errors(changeset.errors))
      end

      response = {"data" => App::Serializers::Link.new(link)}
      response.to_json
    end
  end

  class Index < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      slug = env.params.url["slug"]

      link = Database.get_by(Link, slug: slug)
      raise App::NotFoundException.new(env) if !link

      spawn do
        user_agent_str = env.request.headers["User-Agent"]
        user_agent = UserAgent.new(user_agent_str)

        language_header = env.request.headers["Accept-Language"]? || "Unknown"
        language = language_header.split(',').first.split(';').first

        referer = env.request.headers["Referer"]?

        click = Click.new
        click.id = UUID.v4.to_s
        click.link = link
        click.language = language
        click.user_agent = user_agent_str
        click.browser = user_agent.family
        click.os = user_agent.os.try &.family || "Unknown"
        click.source = referer ? URI.parse(referer).host : "Unknown"

        changeset = Database.insert(click)
        if changeset.errors.any?
          Log.error { "Logging click event failed: #{changeset.errors}" }
        end
      end

      env.response.status_code = 301
      env.response.headers["Location"] = link.url!
      env.response.headers["Content-Type"] = "text/html"
      env.response.print("Redirecting...")
    end
  end

  class All < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      user = env.get("user").as(User)

      query = Database::Query.where(user_id: user.id.as(String))
      links = Database.all(Link, query, preload: [:clicks])

      response = {"data" => links.map { |link| App::Serializers::Link.new(link) }}
      response.to_json
    end
  end

  class Get < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      user = env.get("user").as(User)
      link_id = env.params.url["id"]

      query = Database::Query.where(id: link_id.as(String), user_id: user.id.as(String)).limit(1)
      links = Database.all(Link, query, preload: [:clicks])

      if links.empty?
        raise App::NotFoundException.new(env)
      end

      response = {"data" => App::Serializers::Link.new(links.first)}
      response.to_json
    end
  end

  class Update < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      user = env.get("user").as(User)
      id = env.params.url["id"]
      body = parse_body(env, ["url"])

      link = Database.get(Link, id)
      raise App::NotFoundException.new(env) if !link

      if link.user_id != user.id
        raise App::ForbiddenException.new(env)
      end

      link.url = body["url"].to_s

      changeset = Database.update(link)
      if !changeset.valid?
        raise App::UnprocessableEntityException.new(env, map_changeset_errors(changeset.errors))
      end

      response = {"data" => App::Serializers::Link.new(link)}
      response.to_json
    end
  end

  class Delete < App::Lib::BaseController
    include App::Models
    include App::Lib

    def call(env)
      user = env.get("user").as(User)
      id = env.params.url["id"]

      link = Database.get(Link, id)
      raise App::NotFoundException.new(env) if !link

      if link.user_id != user.id
        raise App::ForbiddenException.new(env)
      end

      result = Database.raw_exec("DELETE FROM links WHERE id = (?)", link.id) # tempfix: Database.delete does not work
      if result.rows_affected == 0
        raise App::UnprocessableEntityException.new(env, { "id" => ["Row delete failed"] })
      end

      env.response.status_code = 204
    end
  end
end
