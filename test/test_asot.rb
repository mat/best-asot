#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'rubygems'
require 'mongo_mapper'
require 'lib/models'
require 'test/unit'
require 'rack/test'
require 'lib/asot'

MongoMapper.database = 'bestasottest'

set :environment, :test

class AsotModelTest < Test::Unit::TestCase
  def setup
    Asot.delete_all
    Uservote.delete_all
  end

  def test_set_created_at_and_updated_at
    a = Asot.new(:no => 42, :url => 'http://example.com', :votes => 10)
    assert_nil a.created_at
    assert_nil a.updated_at

    a.save!
    assert_not_nil a.created_at
    assert_not_nil a.updated_at
    assert_equal a.created_at, a.updated_at

    sleep(1.5) #seconds
    a.save!
    assert a.created_at.to_i < a.updated_at.to_i
  end

  def test_grep_the_vote_count_given_a_forum_uri
    votes = Asot.fetch_di_votes('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/')
    assert_equal 25, votes
  end

  def test_grep_the_airdate_given_a_forum_uri
    airdate = Asot.fetch_di_date('http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-369-a-146900/')
    assert_equal Time.local(2008,9,11), airdate
  end

  def test_add_new_episode_with_votes_and_airdate
    url = 'http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-377-a-150099/'
    a = Asot.add_by_url_and_fetch(url)

    assert_equal 377, a.no
    assert_equal 32, a.votes
    assert_equal Time.parse('Thu, 6 Nov 2008'), a.airdate
  end

  def test_to_csv
    a = Asot.create(:no => 123, :airdate => Time.gm(2008, 11, 6), :votes => 1000, :url => "http://foo.com")
    #id;no;url;votes;created_at;updated_at;airdate;notes
    created = a.created_at.strftime('%Y-%m-%d %H:%M:%S')
    updated = a.updated_at.strftime('%Y-%m-%d %H:%M:%S')

    assert_equal "2008-11-06 00:00:00", a.airdate.strftime('%Y-%m-%d %H:%M:%S')
    assert_equal "#{a.id};123;http://foo.com;1000;#{created};#{updated};2008-11-06 00:00:00;\n", a.to_csv
  end

  def test_from_csv
    #id;no;url;votes;created_at;updated_at;airdate;notes
    csv_line = '247;444;http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-444-a-190740/;25;2010-02-18 10:00:01;2010-02-19 12:42:02;2010-02-18 00:00:00;insert notes here'
    a = Asot.from_csv(csv_line)

    assert_equal 444, a.no
    assert_equal "http://forums.di.fm/trance/armin-van-buuren-presents-state-of-trance-episode-444-a-190740/", a.url
    assert_equal 25, a.votes
    assert_equal DateTime.civil(2010,2,18,10,00,01), a.created_at
    assert_equal DateTime.civil(2010,2,19,12,42,02), a.updated_at
    assert_equal DateTime.civil(2010,2,18), a.airdate
    assert_equal "insert notes here", a.notes
  end

  def test_find_by_year
    Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)
    Asot.create!(:no => 2, :airdate => Time.parse('Thu,  6 Nov 2009'), :votes => 10)
    Asot.create!(:no => 3, :airdate => Time.parse('Thu, 13 Nov 2009'), :votes => 10000000000)
    Asot.create!(:no => 4, :airdate => Time.parse('Thu, 20 Nov 2009'), :votes => 100000)

    asots = Asot.find_by_year(2009, "votes DESC")
    assert_equal 3, asots.length

    assert_equal 3, asots[0].no
    assert_equal 4, asots[1].no
    assert_equal 2, asots[2].no
  end

  def test_vote!
    a = Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)

    ok = a.vote!("127.0.0.1")
    assert ok
    assert_equal 1, Uservote.all.size
    assert_equal 1, a.uservotes.size

    a.reload
    assert_equal 1, Uservote.all.size
    assert_equal 1, a.uservotes.size
    assert_equal "127.0.0.1", Uservote.first.ipaddress
    assert_equal "127.0.0.1", a.uservotes.first.ipaddress

    uservote = a.uservotes.all(:ipaddress => "127.0.0.1").first
    assert_equal "127.0.0.1", uservote.ipaddress
  end

  def test_vote_twice_from_same_ip
    a = Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)

    ok = a.vote!("127.0.0.1")
    assert ok

    ok = a.vote!("127.0.0.1")
    assert !ok

    assert_equal 1, a.uservotes.size
  end

  def test_vote_often_from_different_ip_addresses
    a = Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)

    ok = a.vote!("127.0.0.1")
    assert ok
    assert a.uservotes.first(:order => "created_at asc").created_at
    assert_equal Time.now.utc.to_s, a.updated_at.utc.to_s

    ok = a.vote!("192.168.0.1")
    assert ok

    sleep(1.5) #seconds
    ok = a.vote!("192.168.0.42")
    assert ok
    assert a.uservotes.last(:order => "created_at asc").created_at
    assert_equal Time.now.utc.to_s, a.updated_at.utc.to_s

    voted_first = a.uservotes.first(:order => "created_at asc").created_at
    voted_last = a.uservotes.last(:order => "created_at asc").created_at
    assert voted_first < voted_last

    assert_equal 3, a.uservotes.size
  end

end

class AsotTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    Asot.delete_all
    Uservote.delete_all
    create_some_asots
  end

  private
  def assert_stat(expected_code)
    assert_equal expected_code, last_response.status
  end

  def create_some_asots
    @no_1 = Asot.create!(:no => 1, :airdate => Time.parse('Thu,  6 Nov 2008'), :votes => 1000)
    @no_2 = Asot.create!(:no => 2, :airdate => Time.parse('Thu,  6 Nov 2009'), :votes => 10)
    @no_3 = Asot.create!(:no => 3, :airdate => Time.parse('Thu, 13 Nov 2009'), :votes => 10000000000)
    @no_4 = Asot.create!(:no => 4, :airdate => Time.parse('Thu, 20 Nov 2009'), :votes => 100000)
  end

  public
  def test_simple_get
    get "/"
    assert last_response.ok?
    assert last_response['Last-Modified']
    assert_equal Asot.last_update.httpdate, last_response['Last-Modified']
  end

  def test_cached_get_with_fresh_if_modified_since
    last_modified = Asot.last_update

    get "/", {}, 'HTTP_IF_MODIFIED_SINCE' => last_modified.httpdate
    assert_stat 304
    assert last_response['Last-Modified']
    assert_equal last_modified.httpdate, last_response['Last-Modified']
  end


  def test_cached_get_with_stale_if_modified_since
    last_modified = Asot.last_update

    get "/", {}, 'HTTP_IF_MODIFIED_SINCE' => (last_modified - 1000).httpdate
    assert_stat 200
    assert last_response['Last-Modified']
    assert_equal Asot.last_update.httpdate, last_response['Last-Modified']
  end

  def test_post_a_vote
    post "/asots/3/vote"
    assert_stat 201
    assert_equal "#{@no_3.votes} + 1", last_response.body
  end

  def test_post_a_vote_for_non_existent_asot
   post "/asots/42/vote"
   assert_stat 404
  end

  def test_post_a_vote_twice
    post "/asots/3/vote"
    assert_stat 201
    assert_equal "#{@no_3.votes} + 1", last_response.body

    post "/asots/3/vote"
    assert_stat 403
    assert_equal "Already voted.", last_response.body
  end

end
