require "json"

module Picloud
  module Config
    ["aws", "aws_keys", "picassound"].each do |cfg|
      cfg_file = File.join(Picloud.root_dir, "cfg/#{cfg}.json")
      cfg_hash = JSON.parse((File.read cfg_file), :symbolize_names => true)
      cfg_hash.each do |k,v|
        define_singleton_method k do
          v
        end
      end
    end
  end
end
