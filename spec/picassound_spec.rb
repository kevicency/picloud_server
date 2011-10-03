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

  describe :recommend_song_ids do
    before do
      @profile_id = "1"
      @image_data = ":)"
      @image_path = "/path/to/image.jpg"
      @expected_ids = [1,2,3]
      @http_res = mock Net::HTTPSuccess
      @http_res.stub!(:is_a?).with(Net::HTTPSuccess).and_return(true)
      @http_res.stub!(:body).and_return(@expected_ids.to_json)

      Picassound.should_receive(:store_image)
        .with(@image_data)
        .and_return(@image_path)
      Net::HTTP.should_receive(:post_form)
        .with(URI.parse(@config[:recommend_uri]), {
          Image:@image_path,
          Profile_Id:@profile_id,
          Device_Id:"MyDevice" })
        .and_return(@http_res)
    end
    subject { Picassound.recommend_song_ids(@image_data, @profile_id) }

    it {should == @expected_ids }
  end

  describe :recommend_songs do
    before do
      @profile_id = "1"
      @image_data = ":)"
      @song_ids = [1,2,3]
      @expected_songs = []
      @song_ids.each do |i|
        song = {
          artist: "Artist#{i}",
          title: "Title#{i}" 
        }
        @songlist.should_receive(:[]).with(i).and_return(song)
        @expected_songs << song
      end
      Picassound.should_receive(:get_recommended_song_ids)
        .with(@image_data, @profile_id)
        .and_return(@expected_songs)
    end
    subject { Picassound.recommend_songs(@image_data, @profile_id) }

    it {should == @expected_songs}
  end

 # describe :sync_music do
    #before do
      #@device_id = "MyDevice"
      #@app_id = "1"
      #@songs = [{id:"1"}]
      #@profile = {device_id:@device_id, songs:@songs, app_id:@app_id}

      #Profile.should_receive(:create).with(@device_id, @songs, @app_id).and_return(@profile)
      #Profile.should_receive(:store).with(@profile)
    #end
    #subject { Picassound.sync_music(@device_id, @songs, @app_id) }

    #it { should == @profile[:id] }
  #end

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
