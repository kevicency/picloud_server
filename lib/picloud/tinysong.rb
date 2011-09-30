require "grooveshark/tiny_song"
require "json"

module Picloud

  class << (TinySong = Object.new)

    def grooveshark_ids(songs)
      songs.map do |song|
        query = "#{song[:artist]} #{song[:title]}"
        json = Grooveshark::TinySong.meta(api_key, query)
        res = JSON.parse(json, :symbolize_names => true)
        res[:SongId]
      end
    end

    def api_key
      if @api_key.nil?
        @keys = JSON.parse((File.read "/local/picassound/aws_keys.json"), :symbolize_names => true)
        @api_key = keys[:tiny_song]
      end
      return @api_key
    end
  end

end
