require "net/http"
require "json"
require "uuidtools"

## Picloud::Picassound

# Ruby interface for the *Picassound* Web Service
module Picloud
  class Picassound

    DEFAULT_ENDPOINT = "http://localhost:8080/iOS/Recommend"
    DEFAULT_IMAGE_DIR = "/local/picassound/images"

    # Creates a new Picassound instance. It expects two parameters:
    #
    # * `endpoint`: Endpoint of the Picassound web service. _Defaults to
    # Picassound::DEFAULT_ENDPOINT_.
    #
    # * `image_dir`: Directory where the images are stored. _Defaults to
    # Picassound::DEFAULT_IMAGE_DIR_.
    #
    def initialize(endpoint = nil, image_dir = nil)
      @endpoint = URI.parse(endpoint || DEFAULT_ENDPOINT)
      @image_dir = image_dir || DEFAULT_IMAGE_DIR
    end

    # Recommends songs for an `image` from the list of `available_song_ids`.
    # If `available_song_ids` is omitted, all known songs are used for
    # recommendation
    def recommend(image, available_song_ids = nil)
      image_file = store_image image
      params = {
        Image: image_file
      }
      params[:SongIds] = available_song_ids.join(",") unless available_song_ids.nil?

      request params
    end

    # Recommends songs for an `image`. The list of available songs is derived
    # from the Profile which belongs to the `profile_id`
    def recommend_for_profile(image, profile_id)
      image_file = store_image image
      params = {
        Image: image_file,
        ProfileId: profile_id
      }
      request params
    end

    ## Private Methods

    private

    # Creates the params for the recommendation request
    def recommend_params(image_file, song_ids = nil)
      params = { Image: image_file }
      params[:SongIds] = song_ids.join(",") unless song_ids.nil?

      return params
    end

    # Request the recommended songs for `params` from the Picassound Web Service
    def request(params)
      res = Net::HTTP.post_form(@endpoint, params)

      if res.is_a? Net::HTTPSuccess
        JSON.parse(res.body)
      else
        raise Picloud::RecommendationError.new res.message
      end
    end

    # Stores the `image` on disk and returns the path to the `image`
    def store_image(image)
      name = "#{UUIDTools::UUID.random_create.to_s}.#{image[:type]}"
      path = File.join(@image_dir, name)
      File.open(path, "w") {|f| f.write image[:data]}

      path
    end
  end
end
