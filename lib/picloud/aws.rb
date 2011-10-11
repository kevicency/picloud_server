# # Picloud::Aws
# A minimal wrapper for *Amazon Web Services* using
# [RightAws](http://rightscale.rubyforge.org/right_aws_gem_doc/)

require 'json'
require 'right_aws'

module Picloud
   class Aws
    attr_reader :access_key, :secret_key, :bucket_name, :queue_name

    # `Aws.new` requires the `access_key` and `secret_key` of the
    # Amazon Web Service account.
    # The `options` hash is optional and may contain:
    #
    # * `:bucket_name`: name of the S3 bucket. _Defaults to `picassound`_.
    #
    # * `:queue_name`: name of the SQS queue. _Defaults to `picassound`_.
    #
    # * `:s3`: params for the S3 Interface. _Defaults to `{}`_.  
    #   See [RightAws::S3](http://rightscale.rubyforge.org/right_aws_gem_doc/classes/RightAws/S3.html).
    #
    # * `:sqs`: params for the SQS Interface. _Defaults to `{}`_.  
    #   See [RightAws::SQS](http://rightscale.rubyforge.org/right_aws_gem_doc/classes/RightAws/Sqs.html).
    def initialize(access_key, secret_key, options = {})
      @access_key = access_key
      @secret_key = secret_key
      @bucket_name = options[:bucket_name] || "picassound"
      @queue_name = options[:queue_name] || "picassound"
      @s3_params = options[:s3] || {}
      @sqs_params = options[:sqs] || {}
    end

    # The S3 bucket
    def bucket
      s3.bucket @bucket_name
    end

    # The SQS queue
    def queue
      sqs.queue @queue_name
    end

    private

    def s3
      @s3 ||= RightAws::S3.new(@access_key,
                               @secret_key,
                               @s3_params)
    end

    def sqs
      @sqs ||= RightAws::SqsGen2.new(@access_key,
                                     @secret_key,
                                     @sqs_params)
    end
  end
end
