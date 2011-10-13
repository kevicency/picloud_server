$:.unshift "lib"
require "picloud"
require 'sinatra'

set :environment, :production
#disable :run

#FileUtils.mkdir_p 'log' unless File.exists?('log')
#log = File.new("log/sinatra.log", "a")
#$stdout.reopen(log)
#$stderr.reopen(log)

run Picloud::Server.new


