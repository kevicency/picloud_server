$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"

require "picloud/errors"
require "picloud/picassound"
require "picloud/profile"
require "picloud/s3_entity"
require "picloud/server"
require "picloud/server_legacy"
require "picloud/songlist"

module Picloud
  def self.version
    "0.6.0".freeze
  end
end
