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
  raise "./cfg/aws_keys.json not found" unless File.exists? "./cfg/aws_keys.json"

  root = "/local/picassound/"
  index_dir = "#{root}index/"

  Dir.mkdir root unless Dir.exists? root
  Dir.mkdir index_dir unless Dir.exists? index_dir

  system "sudo rm #{root}*.json -r"
  Dir.glob "./cfg/*.json" do |file|
    system "sudo ln #{file} #{root}#{File.basename file}"
    puts "Linked #{file}"
  end
end

task :default => :run
