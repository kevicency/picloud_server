require "json"
require "picloud/s3_entity"

## Picloud::Profile

# A *Profile* associates a subset of the available songs with an user.

module Picloud
  class Profile
    # Include the *S3Entity* mixin to save the *Profile* on S3
    include S3Entity

    # Id of the device used to create the *Profile*
    attr_reader :device_id
    # Songs associated with this profile
    attr_reader :songs

    # Creates a new *Profile* with the specified `device_id` and `songs`.
    # If no `id` is passed, a fresh id is generated.
    def initialize(device_id, songs, id = nil)
      @id = id
      @device_id = device_id
      @songs = songs
    end

    def song_ids
      @songs.map { |song| song[:id] }
    end

    # JSON representation of the *Profile*.
    # This method is required by the *S3Entity* Mixin.
    def serialize
      {
        id: id,
        device_id: device_id,
        songs: songs
      }.to_json
    end

    # Create a *Profile* from JSON representation.
    # This method is required by the *S3Entity* Mixin.
    def self.deserialize(json)
      data = JSON.parse(json, :symbolize_names => true)
      Profile.new(data[:device_id], data[:songs], data[:id])
    end
  end
end
