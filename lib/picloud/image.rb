require "picloud/config"
require "uuidtools"

module Picloud
  class Image
    attr_reader :data, :type, :size, :id, :path

    def initialize(type, data)
      @type = type
      @data = data
      @size = data.length
    end

    def id
      @id ||= UUIDTools::UUID.random_create.to_s
    end

    def store
      Dir.mkdir Config.image_dir unless Dir.exists? Config.image_dir
      file_name = "#{id.to_s}.#{type}"
      @path = File.join(Config.image_dir, file_name)
      File.open(path, "w") {|f| f.write data}

      @path
    end
  end
end
