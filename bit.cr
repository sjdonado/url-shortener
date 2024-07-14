require "kemal"

require "./app/config/*"
require "./app/lib/*"
require "./app/models/*"
require "./app/serializers/*"
require "./app/middlewares/*"

require "./app/routes"

add_context_storage_type(App::Models::User)
add_handler(App::Middlewares::Auth.new)

Kemal.run
