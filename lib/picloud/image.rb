require "uuidtools"

## Picloud::Image

# Represents an `Image` used for recommendation

module Picloud
  class Image
    attr_reader :data, :type, :size, :id, :path

    # Creates a new Image. It expects two parameters:
    #
    # * `type`: The type of the image, f.e. "jpeg"
    #
    # * `data`: The image data
    #
    def initialize(type, data)
      @type = type
      @data = data
      @size = data.length
    end

    # An unique id for the `Image`
    def id
      @id ||= UUIDTools::UUID.random_create.to_s
    end

    # Stores the `Image` on disk. The directory where the `Image` will be stored
    # is stored in `Picloud::Config.image_dir`.
    def store
      Dir.mkdir Config.image_dir unless Dir.exists? Config.image_dir
      file_name = "#{id.to_s}.#{type}"
      @path = File.join(Config.image_dir, file_name)
      File.open(path, "w") {|f| f.write data}

      @path
    end
  end
end
