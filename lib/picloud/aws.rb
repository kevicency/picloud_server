require 'json'
require 'right_aws'

#module RightAws
  #class S3Interface
    #alias_method :old_generate_rest_request, :generate_rest_request
    #def generate_rest_request(method, headers)
      #puts headers
      #old_generate_rest_request method, headers
    #end
  #end
#end
module Picloud

  class << (Aws = Object.new)

    def bucket
      s3.bucket aws_config[:bucket_name]
    end

    def queue
      sqs.queue aws_config[:queue_name]
    end

    private

    def aws_config
      if @aws_config.nil?
        @aws_config = JSON.parse((File.read "/local/picassound/aws_keys.json"), :symbolize_names => true)
        @aws_config.merge! JSON.parse((File.read "/local/picassound/aws.json"), :symbolize_names => true)
      end
      return @aws_config
    end

    def s3
      @s3 ||= RightAws::S3.new(aws_config[:access_key],
                               aws_config[:secret_key],
                               aws_config[:s3])
    end

    def sqs
      @sqs ||= RightAws::SqsGen2.new(aws_config[:access_key],
                                     aws_config[:secret_key],
                                     aws_config[:sqs])
    end
  end
end
