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
        {song_count: Picassound.songlist.count}.to_json
      else
        ids.split(",").map do |id|
          Picassound.songlist[id.to_i] if id =~ /\d+/
        end.to_json
      end
    end

    get "/profiles/:id" do
      begin
        content_type :json
        Profile.load(params[:id]).to_json
      rescue UnknownProfileIdError
        halt 404
      rescue CorruptProfileError
        halt 500, "profile corrupted"
      end
    end

    post "/profiles/:id/recommend" do
      puts "Foo"
      image_data = request.body.read
      recommended_songs = Picassound.recommend_songs(image_data, params[:id])

      content_type :json
      recommended_songs.to_json
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
  end
end
