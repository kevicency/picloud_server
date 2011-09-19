require "json"
require "uuidtools"
require "picloud/aws"
require "picloud/string_extensions"

module Picloud

  class << (Profile = Object.new)

    def store(profile)
      key = Aws.bucket.key(profile_key profile)
      if key.exists?
        begin
          loaded_profile = Profile.load key
          if loaded_profile[:device_id] != profile[:device_id]
            raise InvalidDeviceIdError.new profile[:id], profile[:device_id]
          end
        rescue CorruptProfileError
          # just override it
        end
      end

      json_profile = profile.to_json + "\n" #JSON.pretty_generate profile
      Aws.bucket.put((profile_key profile), json_profile)
    end

    def load(profile_id)
      key = profile_id.is_a?(RightAws::S3::Key) ? profile_id : (profile_key profile_id)
      raise UnknownProfileIdError.new profile_id unless key.exists?

      json_profile = Aws.bucket.get key
      begin
        profile = JSON.parse(json_profile, :symbolize_names => true)
      rescue JSON::ParserError => ex
        raise CorruptProfileError.new profile_id, ex.message
      end

      return profile
    end

    def create(device_id, songs, profile_id = nil)
      profile_id = generate_profile_id if profile_id.nil_or_whitespace?

      return {
        id: profile_id,
        device_id: device_id,
        songs: songs
      }
    end

    private

    def profile_key(arg)
      id = arg.is_a?(Hash) ? arg[:id] : arg

      #Aws.bucket.key "profiles/#{id}.json"
      "profiles/#{id}.json"
    end

    def generate_profile_id
      UUIDTools::UUID.random_create.to_s
    end
  end

  class InvalidDeviceIdError < RuntimeError
    attr_accessor :profile_id, :device_id

    def initialize(profile_id, device_id)
      @profile_id = profile_id
      @device_id = device_id
    end
  end

  class UnknownProfileIdError < RuntimeError
    attr_accessor :profile_id

    def initialize(profile_id)
      @profile_id = profile_id
    end
  end

  class CorruptProfileError < RuntimeError
    attr_accessor :profile_id

    def initialize(profile_id, message)
      super message
      @profile_id = profile_id
    end
  end
end
