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
      req = build_request image, available_song_ids
      res = Net::HTTP.new(@endpoint.host, @endpoint.port).start{|http| http.request(req)}
      if res.is_a? Net::HTTPSuccess
        JSON.parse(res.body)
      else
        raise Picloud::RecommendationError.new res.message
      end
    end

    ## Private Methods

    private

    # Builds the HTTP::Post request for the Picassound Web Service and returns
    # it
    def build_request(image, available_song_ids)
      path = @endpoint.path
      path += "?SongIds=#{available_song_ids.join ","}" unless available_song_ids.nil?
      req = Net::HTTP::Post.new path
      req.body = image.data
      req.content_length = image.size
      req.content_type = "image/#{image.type}"

      return req
    end
  end
end
