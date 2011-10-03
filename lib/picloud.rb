$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"

require "picloud/aws"
require "picloud/picassound"
require "picloud/songlist"
require "picloud/profile"
require "picloud/server"
require "picloud/server_services"
require "picloud/server_legacy"

module Picloud
  def self.version
    "0.6.0".freeze
  end
end
