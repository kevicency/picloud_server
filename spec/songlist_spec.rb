require "picloud/songlist"

include Picloud

SONG_FILE = File.join((File.dirname __FILE__),"data/songs")
#content
#Artist1\_/Title1
#Artist2\_/Title2
#Artist3\_/Title3
#Artist4\_/Title4

INVALID_SONG_FILE = File.join((File.dirname __FILE__),"data/invalid_songs")
#content
#Artist1\_/Title1
#i am invalid !
#Artist2\_/Title3

def songify(artist, title, id = nil)
  song = { artist:artist, title:title }
  song[:id] = id unless id.nil?

  return song
end

describe Songlist do

  describe "when passing a valid song file" do
    before do
      @songlist = Songlist.new SONG_FILE
      @known_artist = "Artist2"
      @known_title = "Title2"
      @known_id = 1
      @unknown_artist = "Foo"
      @unknown_title = "Bar"
      @known_song = songify(@known_artist, @known_title, @known_id)
      @known_song_no_id = songify(@known_artist, @known_title)
      @unknown_song = songify(@unknown_artist, @unknown_title, @unknown_id)
    end

    subject { @songlist }

    its (:count) { should == 4 }
    its [1] { should == @known_song }

    describe :get_id do

      describe "when passing a song without id" do
        it "searches for the song and returns its id" do
          subject.should_receive(:find).with(@known_song_no_id).and_return(@known_song)
          subject.get_id(@known_song_no_id).should == 1
        end
      end

      describe "when passing a song with an id" do
        it "simply returns the id" do
          subject.should_not_receive(:find).with(@known_song)
          subject.get_id(@known_song).should == 1
        end
      end
    end

    describe :find do
      describe "when passing a song with valid artist and title" do
        subject { @songlist.find @known_song_no_id }

        its [:id] { should == @known_song[:id] }
      end

      describe "when passing a song with valid artist and title in different case" do
        subject { @songlist.find songify(@known_artist.upcase, @known_title.upcase) }

        its [:id] { should == @known_song[:id] }
      end

      describe "when passing a song with valid artist but invalid song" do
        subject { @songlist.find(songify @known_artist, @unknown_title) }

        its [:id] { should be_nil }
      end

      describe "when passing a song with invalid artist but valid song" do
      subject { @songlist.find(songify @unknown_artist, @known_title) }

      its [:id] { should be_nil }
      end
    end
  end

  describe "when passing a song with invalid song(s)" do
    subject { Songlist.new INVALID_SONG_FILE }
    its (:count) { should == 2 }
  end
end
