require "picloud/picassound"

include Picloud

describe Picassound do
  before do
    @config = {
      recommend_uri: "http://localhost:8080/iOS/Recommend",
      song_file: "song_file"
    }
    @songlist = mock(Songlist)

    File.stub!(:read).with("/local/picassound/picassound.json")
    JSON.stub!(:parse).and_return @config
    Songlist.stub!(:new).and_return @songlist
  end

 # subject { Picassound }

  #it "gets initialized" do
    #Picassound.should_not == nil?
  #end

  describe :recommend do
    before do
      @device_id = "MyDevice"
      @app_id = "1"
      @image_data = "image data"
      @http_res = mock Net::HTTPResponse
      @http_res.stub!(:code).and_return "200"
      @http_res.stub!(:body).and_return(["1","2","3"].join("\r\n"))
      @recommended_songs = []
      (1..3).each do |i|
        song = {
          artist: "Artist#{i}",
          title: "Title#{i}" 
        }
        @songlist.should_receive(:[]).with(i).and_return(song)
        @recommended_songs << song
      end

      Net::HTTP.should_receive(:post_form)
        .with(URI.parse(@config[:recommend_uri]), {App_Id:@app_id, Device_Id:@device_id})
        .and_return(@http_res)
    end
    subject { Picassound.recommend(@device_id, @app_id, @image_data) }

    it {should == @recommended_songs }
  end

  describe :sync_music do
    before do
      @device_id = "MyDevice"
      @app_id = "1"
      @songs = [{id:"1"}]
      @profile = {device_id:@device_id, songs:@songs, app_id:@app_id}

      Profile.should_receive(:create).with(@device_id, @songs, @app_id).and_return(@profile)
      Profile.should_receive(:store).with(@profile)
    end
    subject { Picassound.sync_music(@device_id, @songs, @app_id) }

    it { should == @profile[:id] }
  end

  #describe :recommend_uri do
    #subject { Picassound.recommend_uri }

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
