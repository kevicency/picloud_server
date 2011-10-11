require "json"
require "uuidtools"
require "picloud/aws"
require "picloud/errors"

module Picloud

  class << (Profile = Object.new)

    def store(profile)
      key = profile_key profile
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

      json_profile = profile.to_json.encode(Aws.encoding)
      Aws.bucket.put(key, json_profile, {}, nil, {'content-type' => "application/json"})
    end

    def load(profile_id)
      key = profile_id.is_a?(RightAws::S3::Key) ? profile_id : (profile_key profile_id)
      raise UnknownProfileIdError.new profile_id unless key.exists?

      json_profile = (Aws.bucket.get key).encode("UTF-8")
      begin
        profile = JSON.parse(json_profile, :symbolize_names => true)
      rescue JSON::ParserError => ex
        raise CorruptProfileError.new profile_id, ex.message
      end

      return profile
    end

    def create(device_id, songs, profile_id = nil)
      if profile_id.nil? || profile_id.whitespace?
        profile_id = generate_profile_id
      end

      return {
        id: profile_id,
        device_id: device_id,
        songs: songs
      }
    end

    def delete(profile_id)
      key = profile_id.is_a?(RightAws::S3::Key) ? profile_id : (profile_key profile_id)
      raise UnknownProfileIdError.new profile_id unless key.exists?

      key.delete
    end

    private

    def profile_key(arg)
      id = arg.is_a?(Hash) ? arg[:id] : arg

      Aws.bucket.key "profiles/#{id}.json"
    end

    def generate_profile_id
      UUIDTools::UUID.random_create.to_s
    end
  end
end
