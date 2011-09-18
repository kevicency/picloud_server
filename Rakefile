#require_relative "lib/gumflap/init"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
end

task :console do
  exec "irb -Ilib -picloud"
end

task :run do
  exec "rvmsudo rackup -p 80"
end

task :link do
  dir = "/local/picassound/"
  system "sudo rm #{dir}*.json -r"
  Dir.glob "./cfg/*.json" do |file|
    system "sudo ln #{file} #{dir}#{File.basename file}"
  end
end

task :default => :run
