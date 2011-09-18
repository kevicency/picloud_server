require "picloud/picassound"

include Picloud



describe Picassound do
  before do
    @config = {
      recommend_uri: "http://localhost:8080/iOS/Recommend",
      song_file: "song_file"
    }
    @songlist = mock(Songlist)

    File.should_receive(:read).with("/local/picassound/picassound.json")
    JSON.should_receive(:parse).and_return @config
    Songlist.should_receive(:new).and_return @songlist

    @picassound = Picassound.new
  end

  subject { @picassound }

  it "gets initialized" do
    @picassound.should_not == nil?
  end

  describe :recommend do
    before do
      @device_id = "MyDevice"
      @app_id = "1"
      @image_data = "image data"
      @http_res = (1..3).map do |i|
          ["Artist#{i}","Title#{i}"]
      end.flatten.join("\r\n")
      @recommended_songs = (1..3).map do |i|
        { artist: "Artist#{i}", title: "Title#{i}" }
      end

      Net::HTTP.should_receive(:post_form)
        .with(@config[:recommend_uri], {App_Id:@app_id, Device_Id:@device_id})
        .and_return(@http_res)
    end
    subject { recommend(@device_id, @app_id, @image_data) }

    it {should == @recommended_songs }
  end

  describe :sync_music do
    before do
      @device_id = "MyDevice"
      @app_id = "1"
      @songs = ["songs"]
      @profile = {device_id:@device_id, songs:@songs, app_id:@app_id}

      self.should_receive(:create_profile).with(@device_id, @songs, @app_id).and_return(@profile)
      self.should_receive(:store_profile).with(@profile)
    end
    subject { sync_music(@device_id, @songs, @app_id) }

    it { should == profile[:id] }
  end

  #describe :recommend_uri do
    #subject { @picassound.recommend_uri }

    #it { should == URI.parse(@config[:recommend_uri]) }
  #end

  #describe :recommend_params do
    #describe "when only passing a device id" do
      #subject { recommend_params("MyDevice", nil, nil) }

      #its [:App_Id] { should == "null" }
      #its [:Device_Id] { should == "MyDevice" }
    #end

    #describe "when passing a device id and an app id" do
      #subject { recommend_params("MyDevice", "1", nil) }

      #its [:App_Id] { should == "1" }
      #its [:Device_Id] { should == "MyDevice" }
    #end
  #end

  #describe :recommend_query do
    #describe "when doing a valid request" do
      #before do
        #@params = "valid params"
        #@response = mock(Net::HTTPResponse)
        #@response.stub!(:code).and_return "200"
        #@response.stub!(:body).and_return "ok"
        #Net::HTTP.should_receive(:post_form).with(recommend_uri, @params).and_return(@response)
      #end
      #subject { recommend_query @params }

      #it { should == @response.body }
    #end

    #describe "when doing an invalid request" do
      #before do
        #@params = "invalid params"
        #@response = mock(Net::HTTPResponse)
        #@response.stub!(:code).and_return "500"
        #@response.stub!(:message) == "error"
        #Net::HTTP.should_receive(:post_form).with(recommend_uri, @params).and_return(@response)
      #end

      #it "raises an error " do
        #lambda { recommend_query @params }.should raise_error
      #end
    #end
  #end

  #describe :parse_recommend_result do
    #describe "when result contains two songs" do
      #subject { parse_recommend_result(["Artist1","Title1","Artist2","Title2"].join("\r\n")) }

      #its [0] { should == { artist:"Artist1", title:"Title1" } }
      #its [1] { should == { artist:"Artist2", title:"Title2" } }
    #end
  #end
end
