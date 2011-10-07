require "rake/testtask"
require "json"

#Rake::TestTask.new do |t|
#t.libs << "test"
#t.test_files = FileList["test/test_*.rb"]
#end

task :console do
  exec "irb -Ilib -picloud"
end

task :run => :setup do
  exec "rvmsudo thin -R config.ru -p 80 -d"
end

task :setup => [:check_picassound, :copy_configs, :load_ec2_metadata] do

end

task :load_ec2_metadata do
  metadata_file = "/local/ec2-metadata"

  unless File.exists? metadata_file
    system "sudo wget http://s3.amazonaws.com/ec2metadata/ec2-metadata -O #{metadata_file}"
    system "sudo chmod 555 #{metadata_file}"
    puts "ec2 metadata file downloaded"
  end
end

task :copy_configs do
  config_files = ["aws", "aws_keys", "picassound"]
  local_root = "/local/picassound/"
  config_files.map {|file| "./cfg/#{file}.json" }.each do |file|
    raise "#{file} not found" unless File.exists? file
    system "sudo cp #{file} #{local_root}#{File.basename file} -f"
  end
end

task :check_picassound do
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

task :startup => :nostartup do
  startup_file = "./lib/picloud/startup.rb"
  system "sudo cp #{startup_file} /etc/init.d/picloud -f"
  system "sudo chmod 777 /etc/init.d/picloud"
  system "sudo update-rc.d -f picloud defaults"
end

task :nostartup do
  system "sudo rm /etc/init.d/picloud"
  system "sudo update-rc.d picloud remove"
end

task :default => :run
