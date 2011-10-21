$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"

module Picloud
  def self.root_dir
    File.expand_path("../..", __FILE__)
  end

  def self.version
    "0.6.0".freeze
  end
end

require "picloud/config"
require "picloud/errors"
require "picloud/image"
require "picloud/picassound"
require "picloud/profile"
require "picloud/s3_entity"
require "picloud/server"
require "picloud/server_legacy"
require "picloud/songlist"


