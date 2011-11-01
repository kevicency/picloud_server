$:.unshift "lib"

require 'sinatra'

set :environment, :production
disable :run

require "picloud"

run Picloud::Server.new


