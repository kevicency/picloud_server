require "rake/testtask"

#Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.test_files = FileList["test/test_*.rb"]
#end

task :console do
  exec "irb -Ilib -picloud"
end

task :run do
  exec "rvmsudo rackup -p 80"
end

task :setup do
  metadata_file = "/local/ec2-metadata"
  unless File.exists? metadata_file
    system "sudo wget http://s3.amazonaws.com/ec2metadata/ec2-metadata -O #{metadata_file}"
    system "sudo chmod u+x #{metadata_file}"
    puts "ec2 metadata file downloaded"
  end

  #json stuff
  raise "./cfg/aws_keys.json not found" unless File.exists? "./cfg/aws_keys.json"

  root = "/local/picassound/"
  index_dir = "#{root}index/"

  Dir.mkdir root unless Dir.exists? root
  Dir.mkdir index_dir unless Dir.exists? index_dir

  system "sudo rm #{root}*.json -f"
  Dir.glob "./cfg/*.json" do |file|
    system "sudo ln #{file} #{root}#{File.basename file}"
    puts "Linked #{file}"
  end
end

task :default => :run
