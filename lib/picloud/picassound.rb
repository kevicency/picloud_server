require "net/http"
require "json"
require "uuidtools"
require "picloud/profile"
require "picloud/songlist"

module Picloud

  class << (Picassound = Object.new)

    def recommend_for_profile(image_data, profile_id)
      image_path = store_image image_path
      params = {
        Image: image_path,
        ProfileId: profile_id
      }
      post_request params
    end

    def recommend(image_data, available_song_ids)
      image_path = store_image image_path
      params = recommend_params(image_path, available_song_ids)

      post_request params
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

    def recommend_params(image_path, song_ids = nil)
      params = { Image: image_path }
      params[:SongIds] = song_ids.join(",") unless song_ids.nil?

      return params
    end

    def post_request(params)
      res = Net::HTTP.post_form(recommend_uri, params)

      if res.is_a? Net::HTTPSuccess
        ids = JSON.parse(res.body)
        ids.map do |id|
          songlist[id.to_i]
        end
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
