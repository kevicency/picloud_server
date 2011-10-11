module Picloud

  # Raised when the device id doesnt match the Profile
  class InvalidDeviceIdError < RuntimeError
    # Id of the Profile
    attr_accessor :profile_id
    # Id of the device
    attr_accessor :device_id

    def initialize(profile_id, device_id)
      @profile_id = profile_id
      @device_id = device_id
    end
  end

  # Raised when a Profile was not found
  class UnknownProfileError < RuntimeError
    # Id of the Profile
    attr_accessor :profile_id

    def initialize(profile_id)
      @profile_id = profile_id
    end
  end

  # Raised when a Profile could not be loaded corectly
  class CorruptProfileError < RuntimeError
    # Id of the Profile
    attr_accessor :profile_id

    def initialize(profile_id, message)
      super message
      @profile_id = profile_id
    end
  end
end
