#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'rubygems'
require 'activerecord'
require 'lib/models'
require 'test/unit'
require 'sinatra/test/unit'
require 'lib/asot'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile =>  'db/test.sqlite3'
)

class AsotModelTest < Test::Unit::TestCase
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
    no_1 = Asot.create(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)
    no_2 = Asot.create(:no => 2, :airdate => Time.parse('Thu,  6 Nov 2009'), :votes => 10)
    no_3 = Asot.create(:no => 3, :airdate => Time.parse('Thu, 13 Nov 2009'), :votes => 10000000000)
    no_4 = Asot.create(:no => 4, :airdate => Time.parse('Thu, 20 Nov 2009'), :votes => 100000)
    [no_1,no_2,no_3,no_4].each{ |x| x.save! }

    assert_equal 3, no_1.rank
    assert_equal 4, no_2.rank
    assert_equal 1, no_3.rank
    assert_equal 2, no_4.rank

    assert_equal 1, no_1.yearrank
    assert_equal 3, no_2.yearrank
    assert_equal 1, no_3.yearrank
    assert_equal 2, no_4.yearrank
  end

  def test_add_new_episode_with_votes_and_airdate
    url = 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-377-a-150099/'
    a = Asot.add_by_url_and_fetch(url)

    assert_equal 377, a.no
    assert_equal 32, a.votes
    assert_equal Time.parse('Thu, 6 Nov 2008'), a.airdate
  end

end

class AsotTest < Test::Unit::TestCase
  def setup
    Asot.delete_all
    create_some_asots
  end

  private
  def assert_stat(expected_code)
    assert_equal expected_code, status
  end

  def create_some_asots
    Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)
    Asot.create!(:no => 2, :airdate => Time.parse('Thu,  6 Nov 2009'), :votes => 10)
    Asot.create!(:no => 3, :airdate => Time.parse('Thu, 13 Nov 2009'), :votes => 10000000000)
    Asot.create!(:no => 4, :airdate => Time.parse('Thu, 20 Nov 2009'), :votes => 100000)
  end

  public
  def test_simple_get
    get "/"
    assert response.ok?
    assert response['Last-Modified']
    assert_equal Asot.last_update.httpdate, response['Last-Modified']
  end

  def test_cached_get_with_fresh_if_modified_since
    last_modified = Asot.last_update

    get "/", {}, 'HTTP_IF_MODIFIED_SINCE' => last_modified.httpdate
    assert_stat 304
    assert response['Last-Modified']
    assert_equal last_modified.httpdate, response['Last-Modified']
  end


  def test_cached_get_with_stale_if_modified_since
    last_modified = Asot.last_update

    get "/", {}, 'HTTP_IF_MODIFIED_SINCE' => (last_modified - 1000).httpdate
    assert_stat 200
    assert response['Last-Modified']
    assert_equal Asot.last_update.httpdate, response['Last-Modified']
  end

end

