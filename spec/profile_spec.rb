require "picloud/profile"

include Picloud

describe Profile do

  describe "Creating a new profile" do
    let(:device_id) { "MyDevice" }
    let(:songs) { (0..2).map {|i| { id:i } }}
    before { @profile = Profile.new(device_id, songs) }
    subject { @profile }

    its (:device_id) { should == device_id }
    its (:songs) { should == songs }
    its (:song_ids) { should == [0,1,2] }

    describe "and serializing it" do
      subject { @profile.serialize }

      it { should match /\"id\":\"[\w]{8}(-[\w]{4}){3}-[\w]{12}\"/ }
      it { should match /\"device_id\":\"#{device_id}\"/ }
    end
  end

  describe "Deserializing a profile" do
    let (:json) do
      {
        id: "id",
        device_id: "device_id",
        songs: "songs"
      }.to_json
    end
    subject { Profile.deserialize json }

    its (:id) { should == "id" }
    its (:device_id) { should == "device_id" }
    its (:songs) { should == "songs" }
  end

end

