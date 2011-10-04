require "net/http"
require "json"
require "uuidtools"
require "picloud/profile"
require "picloud/songlist"

module Picloud

  class << (Picassound = Object.new)

    def recommend_for_profile(image_data, profile_id = nil)
      image_path = store_image image_data
      params = build_recommend_params(image_path, "MyDevice", profile_id)

      ids = post_request params
      puts ids
      return ids
    end

    def recommend(image_data, available_song_ids)
      image_path = store_image image_path
      params = build_recommend_params(image_path, "MyDevice", available_song_ids)
      ids = recommend_ids image_data, profile_id

      ids.map do |id|
        songlist[id.to_i]
      end
    end

    def songlist
      @songlist ||= Songlist.new config[:song_file]
    end

    private

    def config
      @config ||= JSON.parse((File.read "/local/picassound/picassound.json"), :symbolize_names => true)
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

    def post_request(params)
      res = Net::HTTP.post_form(recommend_uri, params)

      if res.is_a? Net::HTTPSuccess
        return JSON.parse(res.body)
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
