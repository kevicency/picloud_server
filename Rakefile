require "rake/testtask"
require "json"
require "rocco/tasks"

#Rake::TestTask.new do |t|
#t.libs << "test"
#t.test_files = FileList["test/test_*.rb"]
#end

desc "Open irb and load all Picloud libs"
task :console do
  exec "irb -Ilib lib/picloud.rb"
end

desc "Starts the Thin server as a daemon"
task :run => :setup do
  exec "rvmsudo thin start -R config.ru -p 80 -d"
end

desc "Kills the Thin daemon"
task :kill do
  exec "rvmsudo thin stop -R config.ru"
end

desc "Sets up the environment for Picloud"
task :setup => [:validate_picassound, :copy_configs, :load_ec2_metadata] do

end

desc "Downloads the ec2 metadata file"
task :load_ec2_metadata do
  metadata_file = "/local/ec2-metadata"

  unless File.exists? metadata_file
    system "sudo wget http://s3.amazonaws.com/ec2metadata/ec2-metadata -O #{metadata_file}"
    system "sudo chmod 555 #{metadata_file}"
    puts "ec2 metadata file downloaded"
  end
end

desc "Copies the config files from './cfg' to the app folder"
task :copy_configs do
  config_files = ["aws", "aws_keys", "picassound"]
  app_folder = "/local/picassound/"
  config_files.map {|file| "./cfg/#{file}.json" }.each do |file|
    raise "#{file} not found" unless File.exists? file
    system "sudo cp #{file} #{app_folder}#{File.basename file} -f"
  end
end

desc "Validates the existence of all required files/directories"
task :validate_picassound do
  config = File.read "./cfg/picassound.json"
  files = JSON.parse config, :symbolize_names => true
  files.each do |name, path|
    case name
    when /.*file/
      raise "#{path} not found" unless File.exists? path
    when /.*dir/
      raise "#{path} doesn't exist" unless Dir.exists? path
    end
  end
end

desc "Installs Picloud as Thin service with is started on startup and can be started/stoped"
task :thin_service do
  root = File.dirname(__FILE__)
  home = `echo ~`.chomp
  rvm_current = `rvm current`.chomp
  `rvmsudo thin install`
  `rvmsudo update-rc.d -f thin defaults`
  `rvmsudo thin config -C /etc/thin/picloud.yml -c #{root} -d -p 80`
  `rvm wrapper #{rvm_current} bootup thin`
  begin
    thin_init = "/etc/init.d/thin"
    init_content = File.read(thin_init)
    init_content.gsub!(/DAEMON=.*$/, "DAEMON=#{home}/.rvm/bin/bootup_thin")
    File.open(thin_init,"w"){|f| f.write init_content}
  rescue
    puts "Couldn't edit #{thin_init}. Please run 'rvmsudo rake thin_service'"
  end
end

# Documentation with Rocco
Rocco::make 'docs/'

desc 'Build rocco docs'
task :docs => :rocco

# Alias for docs task
task :doc => :docs

task :default => :run
