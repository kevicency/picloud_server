require 'json'
require 'uuidtools'
require 'right_aws'

## Picloud::S3Entity

# Mixin which enables CRUD operations for S3 backed entities.
#
# Requires the including class to implement `serialize` and
# `self.deserialize(json)`.
#

module Picloud
  module S3Entity

    ### Class Methods

    module ClassMethods

      # Returns `true` when an entity with the id exists. `false` otherwise
      def exists?(id)
        (key id).exists?
      end

      # Loads the *S3Entity* with the specified `id` from S3
      def load(id)
        key = (key id)
        raise Picloud::UnknownEntityError.new id unless key.exists?

        begin
          json = (bucket.get key).encode("UTF-8")
          deserialize json
        rescue Error => ex
          raise Picloud::CorruptEntityError.new id, ex.message
        end
      end

      def delete(id)
        ((key id).delete if exists? id) || false
      end

      # S3 Interface
      def s3
        @s3 ||= RightAws::S3.new(Config.access_key,
                                 Config.secret_key,
                                 Config.s3)
      end

      # The S3 bucket
      def bucket
        s3.bucket Config.bucket_name
      end

      # Returns a bucket key for `id`
      def key(id)
        directory = name.split("::").last.downcase
        bucket.key "#{directory}s/#{id}.json"
      end

      # The encoding to which the JSON string is encoded before uploading
      def encoding
        Config.encoding
      end
    end

    # Add class methods to the `klass` when the mixin is included
    def self.included(klass)
      klass.extend ClassMethods
    end

    ### Instance Methods

    # Returns the bucket key of the *S3Entity*
    def key
      self.class.key(id)
    end

    # Returns the id of the *S3Entity*. If the id is `nil`, a fresh on is
    # generated
    def id
      @id ||= UUIDTools::UUID.random_create.to_s
    end

    # Saves the *S3Entity* to S3
    def save
      json = serialize.encode(self.class.encoding)
      self.class.bucket.put(key, json, {}, nil, {'content-type' => "application/json"})
    end

    # Deletes the *S3Entity* from S3
    def delete
      key.exists? ? key.delete : false
    end
  end
end
