require "picloud/picassound"
require "picloud/errors"

module Picloud

  class Server

    get "/songs/:id" do
      id = params[:id]
      song = Picassound.songlist[id.to_i] if id =~ /\d+/

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
        {song_count: Picassound.songlist.length}.to_json
      else
        ids.split(",").map do |id|
          Picassound.songlist[id.to_i] if id =~ /\d+/
        end.to_json
      end
    end

    post "/profiles" do
      halt 400 if request.content_type != "application/json"
      json = request.body.read
      begin
        profile = JSON.parse(json, :symbolize_names => true)
        Profile.store(profile)
      rescue InvalidDeviceIdError
        halt 401
      rescue JSON::ParserError => ex
        halt 400, "Malformed JSON\n{ex}"
      end
    end

    get "/profiles/:id" do
      begin
        profile = Profile.load(params[:id]).to_json

        content_type :json
        profile
      rescue UnknownProfileIdError
        halt 404
      rescue CorruptProfileError
        halt 500, "profile corrupted"
      end
    end

    delete "/profiles/:id" do
      begin
        Profile.delete(params[:id])
      rescue UnknownProfileIdError
        halt 404
      end
    end

    post "/profiles/:id/recommend" do
      image = {
        type: (get_image_type request.content_type),
        data: (request.body.read)
      }
      halt 400, "Invalid Content-Type" unless image[:type]
      recommended_songs = Picassound.recommend_for_profile(image, params[:id])

      content_type :json
      recommended_songs.to_json
    end

    post "/recommend" do
      image = {
        type: (get_image_type request.content_type),
        data: (request.body.read)
      }
      halt 400, "Invalid Content-Type" unless image[:type]
      ids = params[:song_ids].split(",").map{|id| id.to_i} if params[:song_ids]
      recommended_songs = Picassound.recommend(image, ids)

      content_type :json
      recommended_songs.to_json
    end

    private

    def get_image_type(content_type)
      match = content_type.match /image\/(?<type>\w+)/ if content_type
      match[:type] if match
    end
  end
end
