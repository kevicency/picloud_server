$:.unshift "lib"
require "picloud"

map "/" do
  run Picloud::Server
end

