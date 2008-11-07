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

  it "should remove the 'index...html from a di.fm uri path" do
    url = "http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-350-live-140099/index89.html"
    Asot.remove_index_html_from_path(url).should== "http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-350-live-140099/"
  end

  it "should sanity check the url for presence of ep no" do
    Asot.check_url(350, '...episode-350-live').should== true
    Asot.check_url(42, '...episode-350-live').should== false
  end

  it "should sanity check the airdate" do
    Asot.date_is_thursday?(Time.parse('Thu, 30 Oct 2008')).should== true
    Asot.date_is_thursday?(Time.parse('Thu, 29 Oct 2008')).should== false
  end

  it "should calculate the rank for an episodes based on the votes" do
    a = Asot.create(:no => 1, :votes => 1)
    b = Asot.create(:no => 2, :votes => 10)
    c = Asot.create(:no => 3, :votes => 100)
    [a,b,c].each{ |x| x.save! }

    a.rank.should== 3
    b.rank.should== 2
    c.rank.should== 1
  end

  it "should add a new episode and fetch votes and airdate." do
    url = 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-377-a-150099/'
    a = Asot.add_by_url_and_fetch(url)
    
    a.no.should== 377
    a.votes.should== 31
    a.airdate.should== Time.parse('Thu, 6 Nov 2008')
  end
end
