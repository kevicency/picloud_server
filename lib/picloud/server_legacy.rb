module Picloud

  class Server

   post "/MusicSync" do
      profile_id = params[:Profile_Id] || params[:profile_id]
      device_id = params[:Device_Id] || params[:device_id]
      songs = []
      if params[:songs].nil?
        song_index = 0

        while songs.length == song_index do
          song_index += 1
          artist = params["Song#{song_index}_artist"]
          title = params["Song#{song_index}_title"]

          unless artist.nil? || title.nil?
            song = {
              id: nil,
              artist: artist,
              title: title
            }
            songs << song
          end
        end
      else
        songs = JSON.parse params[:songs]
      end

      begin
        profile_id = Picassound.sync_music(device_id, songs, profile_id)
      rescue InvalidDeviceIdError => ex
        halt 403, "Invalid Device Id: #{ex.device_id}"
      end

      content_type :json
      return { Profile_Id:profile_id }.to_json
    end

    post "/Recommend" do
      if params[:Image].nil?
        halt 400
      end
      profile_id = params[:Profile_Id] || params[:profile_id]
      image_data = params[:Image][:tempfile].read

      recommended_songs = Picassound.recommend_songs(image_data, profile_id)

      content_type :json
      return recommended_songs.to_json
    end
  end
end
