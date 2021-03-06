FROM ruby:2.6.3-alpine

ENV APP_PATH /usr/src/app
ENV BUNDLE_VERSION 2.1.4
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENV production

WORKDIR $APP_PATH

EXPOSE $RAILS_PORT

ENV ALPINE_MIRROR "http://dl-cdn.alpinelinux.org/alpine"
RUN echo "${ALPINE_MIRROR}/v3.11/main/" >> /etc/apk/repositories

RUN apk -U add --no-cache \
build-base \
postgresql-dev \
postgresql-client \
tzdata \
nodejs --repository="http://dl-cdn.alpinelinux.org/alpine/v3.11/main/" \
yarn

COPY ./entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

RUN gem install bundler --version "$BUNDLE_VERSION"

COPY ./Gemfile .
COPY ./Gemfile.lock .

RUN bundle install --jobs 20 --retry 5

COPY ./package.json .
COPY ./yarn.lock .

RUN yarn

COPY . .

RUN chmod 600 config/master.key

RUN bundle exec rails assets:precompile

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]