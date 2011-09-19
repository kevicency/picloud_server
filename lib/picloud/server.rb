require "sinatra/base"
require "picloud/picassound"

module Picloud

  class Server < Sinatra::Base

    set :root, File.expand_path("../../..", __FILE__)

    def initialize
      super
      @picassound = Picassound.new
    end

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
        app_id = @picassound.sync_music(device_id, songs, app_id)
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

      recommended = @picassound.recommend(device_id, app_id, image_data)

      list = recommended.map {|song| "#{song[:artist]} - #{song[:title]}"}
      .join "\r\n"
      return "<body><pre>#{list}</pre></body>"
    end

    get '/' do
      erb :index
    end
  end
end
