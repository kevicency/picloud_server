require "net/http"
require "json"
require "picloud/profile"
require "picloud/songlist"

module Picloud

  class Picassound

    def initialize(config = nil)
      @config = config || JSON.parse((File.read "/local/picassound/picassound.json"), :symbolize_names => true)
      @songlist = Songlist.new @config[:song_file]
    end

    def sync_music(device_id, songs, profile_id = nil)
      songs.each { |song| song[:id] = @songlist.get_id(song) }
      profile = Profile.create(device_id, songs, profile_id)
      Profile.store profile

      return profile[:id]
    end

    def recommend(device_id, app_id, image_data)
      params = recommend_params(device_id, app_id)

      res = recommend_query params
      songs = parse_recommend_result res

      return songs
    end

    private

    def recommend_uri
      URI.parse(@config[:recommend_uri])
    end

    def recommend_params(device_id, app_id, image_data=nil)
      app_id = app_id || "null"
      app_id = "null" if app_id.empty?
      params = {
        App_Id: app_id || "null",
        Device_Id: device_id
      }
      return params
    end

    def recommend_query(params)
      res = Net::HTTP.post_form(recommend_uri, params)
      raise res.message if res.code == "500"

      return res.body
    end

    def parse_recommend_result(result)
      songs = []
      return songs if result == "NO_SONGS"

      data = result.split("\r\n")
      for i in 0...data.length/2
        songs << {
          artist: data[i*2],
          title: data[i*2+1]
        }
      end
      return songs
    end
  end
end
