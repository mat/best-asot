require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asot do
  before(:each) do
    @valid_attributes = {
      :no => "1",
      :url => "value for di_url",
      :votes => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Asot.create!(@valid_attributes)
  end

  it "should grep the di.fm forum url given an episode number" do
    Asot.fetch_di_uri(369).should== 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/'
  end

  it "should grep the vote count from a given di.fm forum uri" do
    Asot.fetch_di_votes('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/').should== 25
  end

  it "should grep the airdate from a given di.fm forum uri" do
    Asot.fetch_di_date('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/').should== Time.local(2008,9,11)
  end

end
