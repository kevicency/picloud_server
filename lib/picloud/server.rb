require "sinatra/base"
require "picloud/picassound"

module Picloud

  class Server < Sinatra::Base

    set :root, File.expand_path("../../..", __FILE__)

    post "/MusicSync" do
      app_id = params[:App_Id] || params[:app_id]
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
        params[:songs].split("\r\n").each do |song|
          split = song.split(" - ")
          songs << {
            artist:split[0],
            title:split[1]
          } if split.length == 2
        end
      end

      begin
        app_id = Picassound.sync_music(device_id, songs, app_id)
      rescue InvalidDeviceIdError => ex
        halt 403, "Invalid Device Id: #{ex.device_id}"
      end

      content_type :json
      return { App_Id:app_id }.to_json
    end

    post "/Recommend" do
      if params[:App_Id].nil? || params[:Device_Id].nil?
        halt 400
      end
      app_id = params[:App_Id]
      device_id = params[:Device_Id]
      image_data = params[:image][:tempfile].read unless params[:image].nil?

      recommended_songs = Picassound.recommend(device_id, app_id, image_data)

      content_type :json
      return recommended_songs.to_json
    end

    get "/" do
      if File.exists? "/local/ec2-metadata"
        hostname = `/local/ec2-metadata -p`.slice /ec2.*$/
        "Hello from #{hostname || "kev"}"
      end
    end
  end
end
