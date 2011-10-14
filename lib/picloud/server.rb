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
      config_file = File.join(settings.root, "cfg/picassound.json")
      config = JSON.parse((File.read config_file), :symbolize_names => true)
      @songlist = Songlist.load config[:song_file]
      @picassound = Picassound.new(config[:recommend_endpoint], config[:image_dir])
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
      image = {
        type: (get_image_type request.content_type),
        data: (request.body.read)
      }
      halt 400, "Invalid Content-Type" unless image[:type]

      begin
        recommended_song_ids = @picassound.recommend_for_profile(image, params[:id])

        content_type :json
        recommended_song_ids.map do |id|
          @songlist[id]
        end.to_json
      rescue Picloud::RecommendationError => ex
        puts "error"
        puts ex.message
        halt 400, ex.message
      end
    end

    get "/profiles/:id/recommend" do
      halt 404 unless Profile.exists? params[:id]

      @profile_id = params[:id]
      haml :index
    end

    post "/recommend" do
      image = {
        type: (get_image_type request.content_type),
        data: (request.body.read)
      }
      halt 400, "Invalid Content-Type" unless image[:type]
      ids = params[:song_ids].split(",").map{|id| id.to_i} if params[:song_ids]
      recommended_song_ids = @picassound.recommend(image, ids)

      content_type :json
      recommended_song_ids.map do |id|
        @songlist[id]
      end.to_json
    end

    private

    def get_image_type(content_type)
      match = content_type.match(/image\/(?<type>\w+)/) if content_type
      match[:type] if match
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
