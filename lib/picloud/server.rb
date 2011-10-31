require "sinatra/base"
require "haml"
require "json"
require "picloud/songlist"
require "picloud/profile"

## Picloud::Server

# Webserver which provides a RESTful API for song recommendation

module Picloud
  class Server < Sinatra::Base

    root_dir = File.expand_path("../../..", __FILE__)
    set :root, root_dir

    def initialize
      super
      @songlist = Songlist.load Config.song_file
      @picassound = Picassound.new Config.endpoint
    end

    get "/" do
      haml :index
    end

    get "/songs/:id" do
      id = params[:id]
      song = @songlist[id.to_i] if id =~ /\d+/

      if song
        content_type :json
        song.to_json
      else
        halt 404
      end
    end

    get "/songs" do
      ids = params[:ids]

      content_type :json
      if ids.nil?
        {song_count: @songlist.length}.to_json
      else
        ids.split(",").map do |id|
          @songlist[id.to_i] if id =~ /\d+/
        end.to_json
      end
    end

    post "/profiles" do
      halt 400 if request.content_type != "application/json"
      json = request.body.read
      begin
        profile = Profile.deserialize json
        profile.save
        #rescue InvalidDeviceIdError
        #halt 401
      rescue Error => ex
        halt 400, "Malformed Request\n{ex}"
      end
    end

    get "/profiles/:id" do
      begin
        profile = Profile.load(params[:id])

        content_type :json
        profile.serialize
      rescue UnknownEntityError
        halt 404
      rescue CorruptEntityError
        halt 500, "Profile corrupted"
      end
    end

    delete "/profiles/:id" do
      if Profile.delete(params[:id]) 
        200
      else
        halt 404
      end
    end

    post "/profiles/:id/recommend" do
      begin
        image = get_image request
        profile = Profile.load(params[:id])
        recommended_song_ids = @picassound.recommend(image, profile.song_ids)

        content_type :json
        recommended_song_ids.map do |id|
          @songlist[id]
        end.to_json
      rescue RuntimeError => ex
        halt 400, "Invalid Request.\n#{ex.message}"
      end
    end

    get "/profiles/:id/recommend" do
      halt 404 unless Profile.exists? params[:id]

      @profile_id = params[:id]
      haml :index
    end

    post "/recommend" do
      begin
        image = get_image request
        song_ids = params[:song_ids].split(",").map{|id| id.to_i} if params[:song_ids]
        recommended_song_ids = @picassound.recommend(image, song_ids)

        content_type :json
        recommended_song_ids.map do |id|
          @songlist[id]
        end.to_json
      rescue RuntimeError => ex
        halt 400, "Invalid Request.\n#{ex.message}"
      end
    end

    private

    def get_image(request)
      type_match = request.content_type.match(/image\/(?<type>\w+)/)
      type = type_match[:type] if type_match

      Image.new(type, request.body.read)
    end

    # Endpoint for the Load Balancer healthy check
    get "/healthy" do
      if File.exists? "/local/ec2-metadata"
        hostname = `/local/ec2-metadata -p`.slice /ec2.*$/
        "Hello from #{hostname || "kev"}"
      end
    end

    # 404 Response
    not_found do
      'This is nowhere to be found.'
    end
  end
end
