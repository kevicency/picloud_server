#!/usr/bin/ruby

require 'picloud/s3_entity'

include Picloud

describe S3Entity do

end
#describe Aws do
  #before do
    #@keys = {
      #access_key: "MyAccessKey",
      #secret_key: "MySecretKey"
    #}
    #@config = {
      #bucket_name: "bucket",
      #queue_name: "queue",
      #encoding: "ISO",
      #sqs: { server: "queue.amazonaws.com" },
      #s3: { server: "s3.amazonaws.com" }
    #}
    #@test_config = @keys.merge @config

    #File.stub!(:read).with("/local/picassound/aws.json").and_return(@config.to_json)
    #File.stub!(:read).with("/local/picassound/aws_keys.json").and_return(@keys.to_json)
  #end

  #describe :bucket do
    #before do
      #@bucket = mock(RightAws::S3::Bucket)
      #s3 = mock(RightAws::S3)
      #s3.should_receive(:bucket).with(@test_config[:bucket_name]).and_return(@bucket)
      #RightAws::S3.should_receive(:new).with(
        #@test_config[:access_key],
        #@test_config[:secret_key],
        #@test_config[:s3]
      #).and_return(s3)
    #end
    #subject { Aws.bucket }

    #it { should == @bucket}
  #end

  #describe :queue do
    #before do
      #@queue = mock(RightAws::SqsGen2::Queue)
      #sqs = mock(RightAws::SqsGen2)
      #sqs.should_receive(:queue).with(@test_config[:queue_name]).and_return(@queue)
      #RightAws::SqsGen2.should_receive(:new).with(
        #@test_config[:access_key],
        #@test_config[:secret_key],
        #@test_config[:sqs]
      #).and_return(sqs)
    #end
    #subject { Aws.queue }

    #it { should == @queue}
  #end

  #describe :encoding do
    #subject { Aws.encoding }

    #it { should == @test_config[:encoding] }
  #end
#end
