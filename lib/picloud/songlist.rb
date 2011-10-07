module Picloud

  class Songlist

    def initialize(song_file)
      @songs_by_artist = {}
      @songs_by_id = []
      i = 0
      File.open(song_file, "r:UTF-8") do |file|
        while (line = file.gets) do
          data = line.strip.split '\_/'
          #raise "Invalid song: #{line}" unless data.length == 2
          if data.length == 2
            song = {
              id: i,
              artist: data[0],
             title: data[1]
            }
            add_by_artist song
            add_by_id song
          end
          i += 1
        end
      end if File.exist? song_file
    end

    def get_id(song)
      song[:id] || find(song)[:id]
    end

    def find(song)
      normalized_artist = normalize song[:artist]
      songs = @songs_by_artist[normalized_artist]
      found = songs.find do
        |x| (normalize x[:title]) == (normalize song[:title])
      end unless songs.nil?
      return found || {}
    end

    def count
      return @songs_by_id.length
    end

    def [](id)
      return @songs_by_id[id]
    end

    private

    def add_by_artist(song)
      normalized_artist = (normalize song[:artist])
      if (@songs_by_artist.key? normalized_artist)
        @songs_by_artist[normalized_artist] << song
      else
        @songs_by_artist[normalized_artist] = [song]
      end
    end

    def add_by_id(song)
      @songs_by_id[song[:id]] = song
    end

    def normalize(artist)
      artist.strip.downcase
    end
  end
end
