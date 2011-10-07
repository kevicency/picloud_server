#!/usr/bin/env ruby
#
# picloud       Startup script for Picloud
#
# chkconfig: - 85 15
#

require 'aef/init'

class Picloud < Aef::Init
  BASE_DIR = '/local'
  APPS = {
    "picloud_server" => 80,
  }

  stop_start_delay 3

  # An implementation of the start method
  def start
    APPS.each do |app_name, port|
      app_dir = File.join(BASE_DIR, app_name)
      puts "starting #{app_name} on #{port}..."
      `rvmsudo thin start -d -p #{port} -e production -c #{app_dir} -R config.ru`
    end
  end

  # An implementation of the stop method
  def stop
    APPS.each do |app_name, port|
      app_dir = File.join(BASE_DIR, app_name)
      puts "Stopping #{app_name}..."
      `rvmsudo thin stop -c #{app_dir}`
    end
  end
end

# The parser is only executed if the script is executed as a program, never
# when the script is required in a ruby program
if __FILE__ == $PROGRAM_NAME
  Picloud.parse
end

