
## Picloud::Songlist

# Class for easy access to songs in a song file by index or by artist/title

module Picloud
  class Songlist
    attr_reader :length

    # Initializes a new *Songlist* instance and calls `add` for each song in `songs`.
    def initialize(songs = [])
      @length = 0;
      @songs_by_artist = {}
      @songs_by_id = []
      songs.each do |song|
        add song
      end
    end

    # Loads a *Songlist* from a `song_file`.
    # Returns `nil` when the `song_file` doesn't exist
    #
    # Example `song_file`:
    #
    #     Artist1\_/Title2
    #     Artist2\_/Title2
    #     Artist2\_/Title3
    #
    def Songlist.load(song_file)
      File.open(song_file, "r:UTF-8") do |file|
        i = 0
        songlist = Songlist.new
        while (line = file.gets) do
          data = line.strip.split '\_/'
          if data.length == 2
            song = {
              id: i,
              artist: data[0],
              title: data[1]
            }
            songlist.add song
          end
          i += 1
        end
        songlist
      end if File.exist? song_file
    end

    # Adds a `song`. Expects the `song` to be a hash
    #
    #     {
    #       id: 1,
    #       artist: "Foo",
    #       title: "Bar"
    #     }
    #
    def add(song)
      add_by_artist song
      add_by_id song
      @length += 1
    end

    # Searches for a song with given `artist` and `title`.
    # Returns `nil` when no such song is found
    def find(artist, title)
      normalized_artist = normalize artist
      songs = @songs_by_artist[normalized_artist]
      songs.find do |song|
        (normalize song[:title]) == (normalize title)
      end
    end

    # Array like access to a song by its `id`
    def [](id)
      return @songs_by_id[id]
    end

    # Length of the *Songlist*, i.e. number of songs
    def length
      return @length
    end

    private

    # Adds the `song` to a hash where its `:artist` is the key.
    # The hash is used by the `find` method
    def add_by_artist(song)
      normalized_artist = (normalize song[:artist])
      if (@songs_by_artist.key? normalized_artist)
        @songs_by_artist[normalized_artist] << song
      else
        @songs_by_artist[normalized_artist] = [song]
      end
    end

    # Adds the `song` to the songs array with the songs `:id` as the index.
    # The array is used by the `[]` method
    def add_by_id(song)
      @songs_by_id[song[:id]] = song
    end

    # Normalizes a String
    def normalize(s)
      s.strip.downcase
    end
  end
end
