$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"

require "picloud/aws"
require "picloud/picassound"
require "picloud/picassound_web"
require "picloud/songlist"
require "picloud/profile"
