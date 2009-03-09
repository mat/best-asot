#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'rubygems'
require 'activerecord'
require 'lib/models'
require 'test/unit'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile =>  'db/test.sqlite3'
)

class AsotTest < Test::Unit::TestCase
  def setup
    Asot.delete_all
  end

  def test_grep_the_forum_url_given_an_episode_number
    uri = Asot.fetch_di_uri(369)
    assert_equal 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/', uri
  end

  def test_grep_the_vote_count_given_a_forum_uri
    votes = Asot.fetch_di_votes('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/')
    assert_equal 25, votes
  end

  def test_grep_the_airdate_given_a_forum_uri
    airdate = Asot.fetch_di_date('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/')
    assert_equal Time.local(2008,9,11), airdate
  end

  def test_calculate_rank_based_on_votes
    a = Asot.create(:no => 1, :votes => 1)
    b = Asot.create(:no => 2, :votes => 10)
    c = Asot.create(:no => 3, :votes => 100)
    [a,b,c].each{ |x| x.save! }

    assert_equal 3, a.rank
    assert_equal 2, b.rank
    assert_equal 1, c.rank
  end

  def test_add_new_episode_with_votes_and_airdate
    url = 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-377-a-150099/'
    a = Asot.add_by_url_and_fetch(url)

    assert_equal 377, a.no
    assert_equal 32, a.votes
    assert_equal Time.parse('Thu, 6 Nov 2008'), a.airdate
  end

end

