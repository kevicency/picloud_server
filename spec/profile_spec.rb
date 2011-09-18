require "picloud/profile"

include Picloud

describe Profile do
  before do
    @profile = { id:"1", device_id:"MyDevice" }
  end

  #it { Profile.profile_key("1").should == "profiles/1.json" }
  #it { Profile.generate_profile_id.should match /[\w]{8}(-[\w]{4}){3}-[\w]{12}/ } #uuid

  it "loads the profile" do
      bucket = mock(RightAws::S3::Bucket)
      Profile.should_receive(:bucket).and_return bucket
      bucket.should_receive(:get).with("profiles/1.json").and_return(@profile.to_json)

      loaded = Profile.load @profile[:id]
      loaded.should == @profile
  end

  it "stores the profile" do
      bucket = mock RightAws::S3::Bucket
      Profile.should_receive(:bucket).and_return(bucket)
      bucket.should_receive(:put).with("profiles/1.json", @profile.to_json)

      Profile.store @profile
  end

  describe :create_profile do
    before do
      @device_id = "MyDevice"
      @songs = ["songs"]
      @profile_id = "1"
    end

    describe "when not passing a profile id" do
      subject { Profile.create(@device_id, @songs) }

      its [:device_id] { should == @device_id }
      its [:songs] { should == @songs }
      its [:id] { should match /[\w]{8}(-[\w]{4}){3}-[\w]{12}/}
    end

    describe "when passing a profile id" do
      subject { Profile.create(@device_id, @songs, @profile_id)}

      its [:device_id] { should == @device_id }
      its [:songs] { should == @songs }
      its [:id] { should == @profile_id }
    end

    describe "when passing an empty string as profile id" do
      subject { Profile.create(@device_id, @songs, " ") }

      its [:id] { should match /[\w]{8}(-[\w]{4}){3}-[\w]{12}/}
    end

  end
end
