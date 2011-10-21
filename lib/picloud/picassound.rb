require "net/http"
require "json"

## Picloud::Picassound

# Ruby interface for the *Picassound* Web Service
module Picloud
  class Picassound

    DEFAULT_ENDPOINT = "http://localhost:8080/iOS/Recommend"

    # Creates a new Picassound instance. It expects two parameters:
    #
    # * `endpoint`: Endpoint of the Picassound web service. _Defaults to
    # Picassound::DEFAULT_ENDPOINT_.
    #
    def initialize(endpoint = nil)
      @endpoint = URI.parse(endpoint || DEFAULT_ENDPOINT)
    end

    # Returns the ids of recommended songs for the `image`. The recommended
    # song ids are a subset from the `available_song_ids`.
    # If `available_song_ids` is omitted, all known songs are used for
    # recommendation
    def recommend(image, available_song_ids = nil)
      image_path = image.path || image.store # store the image if it isn't already stored
      params = {
        Image: image_path
      }
      params[:SongIds] = available_song_ids.join(",") unless available_song_ids.nil?

      do_request params
    end

    ## Private Methods

    private

     # Request the recommended songs for `params` from the Picassound Web Service
    def do_request(params)
      res = Net::HTTP.post_form(@endpoint, params)

      if res.is_a? Net::HTTPSuccess
        JSON.parse(res.body)
      else
        raise Picloud::RecommendationError.new res.message
      end
    end
  end
end
