require "sinatra/base"
require "picloud/picassound"
require "haml"

module Picloud

  class Server < Sinatra::Base

    root_dir = File.expand_path("../../..", __FILE__)
    set :root, root_dir

    get "/" do
      haml :index
    end

    get "/foo" do
      erb :foo
    end

    get "/healthy" do
      if File.exists? "/local/ec2-metadata"
        hostname = `/local/ec2-metadata -p`.slice /ec2.*$/
        "Hello from #{hostname || "kev"}"
      end
    end

    not_found do
      'This is nowhere to be found.'
    end
  end
end
