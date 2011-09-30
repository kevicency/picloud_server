require "net/http"
require "json"
require "uuidtools"
require "picloud/profile"
require "picloud/songlist"

module Picloud

  class << (Picassound = Object.new)

    def sync_music(device_id, songs, profile_id = nil)
      songs.each { |song| song[:id] = songlist.get_id(song) unless song[:id]}
      profile = Profile.create(device_id, songs, profile_id)
      Profile.store profile

      return profile[:id]
    end

    def recommend_ids(image_data, device_id = nil, profile_id = nil)
      image_path = store_image image_data
      params = build_recommend_params(image_path, device_id, profile_id)

      ids = get_recommended_song_ids params

      return ids
    end

    def recommend_songs(image_data, device_id = nil, profile_id = nil)
      ids = recommend_ids image_data, device_id, profile_id

      ids.map do |id|
        songlist[id.to_i]
      end
    end

    private

    def config
      @config ||= JSON.parse((File.read "/local/picassound/picassound.json"), :symbolize_names => true)
    end

    def songlist
      @songlist ||= Songlist.new config[:song_file]
    end

    def recommend_uri
      @recommend_uri ||= URI.parse(config[:recommend_uri])
    end

    def build_recommend_params(image_path, device_id, profile_id)
      params = { Image: image_path }
      params[:Profile_Id] = profile_id unless profile_id.nil?
      params[:Device_Id] = device_id unless device_id.nil?

      return params
    end

    def get_recommended_song_ids(params)
      res = Net::HTTP.post_form(recommend_uri, params)

      case res
      when Net::HTTPSuccess
        puts res.body
        JSON.parse(res.body)
      else
        raise res.error!
      end
    end

    def store_image(image_data)
      name = "#{UUIDTools::UUID.random_create.to_s}.jpg"
      path = File.join(config[:image_dir], name)
      File.open(path, "w+") {|f| f.write image_data}

      path
    end
  end
end
