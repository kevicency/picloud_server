require "grooveshark/tiny_song"
require "json"

module Picloud

  class << (TinySong = Object.new)

    def grooveshark_ids(songs)
      ids = []
      songs.each do |song|
        query = "#{song[:artist]} #{song[:title]}"
        begin
        res = Grooveshark::TinySong.meta(api_key, query)
        rescue
          res = nil
        end
        ids << res["SongID"] unless res.nil?
      end
      ids
    end

    def api_key
      if @api_key.nil?
        keys = JSON.parse((File.read "/local/picassound/aws_keys.json"), :symbolize_names => true)
        @api_key = keys[:tiny_song]
      end
      return @api_key
    end
  end

end
