require "sinatra/base"
require "picloud/picassound"
require "picloud/tinysong"
require "haml"

module Picloud

  class Server < Sinatra::Base

    set :root, File.expand_path("../../..", __FILE__)

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
      device_id = params[:Device_Id] || params[:device_id]
      image_data = params[:Image][:tempfile].read

      recommended_songs = Picassound.recommend_songs(image_data, device_id, profile_id)

      content_type :json
      return recommended_songs.to_json
    end

    get "/Play" do
      haml :play
    end

    post "/Play" do
      image_data = request.body.read
      recommended_songs = Picassound.recommend_songs(image_data)

      grooveshark_ids = TinySong.grooveshark_ids(recommended_songs).join ","

      player_html = <<-HTML
      <object width="250" height="250">
        <param name="movie" value="http://grooveshark.com/widget.swf" />
        <param name="wmode" value="window" /><param name="allowScriptAccess" value="always" />
        <param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=#{grooveshark_ids}&style=metal&p=0" />
        <embed src="http://grooveshark.com/widget.swf" type="application/x-shockwave-flash" width="250" height="250" flashvars="hostname=cowbell.grooveshark.com&songIDs=#{grooveshark_ids}&p=0" allowScriptAccess="always" wmode="window" />
      </object>
      HTML

      response.write(player_html)
      response.finish
    end

    get "/" do
      if File.exists? "/local/ec2-metadata"
        hostname = `/local/ec2-metadata -p`.slice /ec2.*$/
        "Hello from #{hostname || "kev"}"
      end
    end

    get "/test" do
      erb :test
    end
  end
end
