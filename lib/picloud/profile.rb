require "json"
require "uuidtools"
require "picloud/aws"

module Picloud

  module Profile
    class << self
      include AWS
    end

    def self.store(profile)
      json_profile = profile.to_json
      bucket.put((profile_key profile[:id]), json_profile)
    end

    def self.load(profile_id)
      raise "#{profile_id} is null" if profile_id.nil?

      json_profile = bucket.get(profile_key profile_id)

      JSON.parse(json_profile, :symbolize_names => true)
    end

    def self.create(device_id, songs, profile_id = nil)
      profile_id = generate_profile_id if profile_id.nil? || profile_id.strip.empty?

      return {
        id: profile_id,
        device_id: device_id,
        songs: songs
      }
    end

    def self.profile_key(id)
      "profiles/#{id}.json"
    end

    def self.generate_profile_id
      UUIDTools::UUID.random_create.to_s
    end

    private_class_method :profile_key, :generate_profile_id
  end
end
