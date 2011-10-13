module Picloud

  ## Picloud::InvalidDeviceIdError

  # Raised when the device id doesnt match the Profile
  class InvalidDeviceIdError < RuntimeError
    # Id of the Profile
    attr_accessor :id
    # Id of the device
    attr_accessor :device_id

    def initialize(id, device_id)
      @id = profile_id
      @device_id = device_id
    end
  end

  ## Picloud::UnknownProfileError

  # Raised when a Profile was not found
  class UnknownEntityError < RuntimeError
    # Id of the Profile
    attr_accessor :id

    def initialize(id)
      @id = id
    end
  end

  ## Picloud::CorruptProfileError

  # Raised when a Profile could not be loaded correctly
  class CorruptEntityError < RuntimeError
    # Id of the Profile
    attr_accessor :id

    def initialize(id, message)
      super message
      @id = profile_id
    end
  end
end
