#!/usr/bin/ruby

require 'picloud/aws'

include Picloud

describe Aws do
  before do
    @keys = {
      access_key: "MyAccessKey",
      secret_key: "MySecretKey"
    }
    @config = {
      bucket_name: "bucket",
      queue_name: "queue",
      sqs: { server: "queue.amazonaws.com" },
      s3: { server: "s3.amazonaws.com" }
    }
    @test_config = @keys.merge @config

    File.stub!(:read).with("/local/picassound/aws.json").and_return(@config.to_json)
    File.stub!(:read).with("/local/picassound/aws_keys.json").and_return(@keys.to_json)
  end

  it { should_not == nil }

  describe :bucket do
    before do
      @bucket = mock(RightAws::S3::Bucket)
      s3 = mock(RightAws::S3)
      s3.should_receive(:bucket).with(@test_config[:bucket_name]).and_return(@bucket)
      RightAws::S3.should_receive(:new).with(
        @test_config[:access_key],
        @test_config[:secret_key],
        @test_config[:s3]
      ).and_return(s3)
    end
    subject { Aws.bucket }

    it { should == @bucket}
  end

  describe :queue do
    before do
      @queue = mock(RightAws::SqsGen2::Queue)
      sqs = mock(RightAws::SqsGen2)
      sqs.should_receive(:queue).with(@test_config[:queue_name]).and_return(@queue)
      RightAws::SqsGen2.should_receive(:new).with(
        @test_config[:access_key],
        @test_config[:secret_key],
        @test_config[:sqs]
      ).and_return(sqs)
    end
    subject { Aws.queue }

    it { should == @queue}
  end
end
