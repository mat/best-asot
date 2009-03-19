require 'activerecord'

class Asot < ActiveRecord::Base
  validates_presence_of :no
  validates_uniqueness_of :no
  validates_uniqueness_of :url, :allow_nil => true
  validates_uniqueness_of :airdate, :allow_nil => true

  YEARS = (2006..Time.now.year).to_a

  # TODO extend ActiveSupport::Memoizable
  # OK, rank and yearrank remain slow as hell for the time being.
  # I give up, they have won. For now.
  #
  # 1. Most SQL-fu won't work because Sqlite does not support it.
  # 2. ActiveRecord's callbacks won't work easily here, only hackish.
  # 3. Memoization should work but we want to cut down memory usage
  #    so this is not an option. If memoization, then write our own.
  #
  # Let's cache this later on HTTP level with Rack::Cache and friends.
  # Oh, and the server is much faster than this old laptop, anyway...
  # If this does not suffice, I shall come back here.
  def rank
    asots = Asot.all(:order => 'votes DESC')
    asots.index(self) + 1
  end

  def yearrank
    return -1 if self.airdate.nil?
    asots = Asot.find_by_year(airdate.year, 'votes DESC')
    asots.index(self) + 1
  end

  def Asot.fetch_di_votes(di_forums_uri)
    require 'hpricot'
    require 'open-uri'
    xpath = "/html/body/div[1]/div/div/table[3]/tr[2]/td[3]/strong/a"
    doc = Hpricot(open(di_forums_uri))
    votes = doc.at(xpath).inner_html.to_i
  end

  def Asot.fetch_di_date(di_forums_uri)
    require 'hpricot'
    require 'open-uri'
    xpath = "/html/body/div[2]/div[1]/div/div/div/table/tr[1]/td[1]"
    doc = Hpricot(open(di_forums_uri))
    airdate = Time.parse(doc.at(xpath).inner_text.strip)
    airdate = Time.local(airdate.year, airdate.month, airdate.day)
  end

  def Asot.fetch_di_playing_track
    require 'hpricot'
    require 'open-uri'
    xpath = "/html/body/table/tr/td/table/tr[2]/td/table/tr/td[1]/table/tr[3]/td[2]/a[1]"
    doc = Hpricot(open('http://www.di.fm/trance/mini.html'))
    doc.at(xpath)['href']
  end

  def Asot.render_graph(for_year = Time.now.year)
   require 'scruffy'

   graph = Scruffy::Graph.new
   graph.title = "#{for_year}: Votes by episode"
   graph.renderer = Scruffy::Renderers::Standard.new

   # add bar for each episode
   asots = find_by_year(for_year, 'airdate ASC')
   votes = asots.map{|a| a.votes }
   graph.add :bar, "", votes

   # overprint top 5 episodes via colored data points
   top_5 = find_by_year(for_year, 'votes DESC')[0..4]
   top_5 = top_5.sort_by{|a| a.no} # legend order = bar order
   top_5.each do |a|
     dataset = Array.new(asots.length){0}
     dataset[asots.index(a)] = a.votes
     graph.add :bar, "##{a.no}", dataset
   end

   graph.render :width => 450, 
                :min_value => 0,
                :max_value => ((votes.max + 20) / 20).floor * 20,
                :to => "public/images/votes_#{for_year}.svg"
   :ok
  end

  def Asot.add_by_url_and_fetch(url)
    a = Asot.new(:url => url)

    a.no      = url.match(/episode-(\d*)/)[1].to_i
    a.airdate = Asot.fetch_di_date(a.url)
    a.votes   = Asot.fetch_di_votes(a.url)

    a.save!
    a
  end

  def to_s
    "##{self.no}, #{self.votes} votes, aired on #{self.airdate}"
  end

  def Asot.last_update
    # SELECT MAX(updated_at) FROM asots
    Asot.first(:order => 'updated_at DESC').updated_at
  end

  def Asot.find_by_year(y, order = 'airdate DESC')
    Asot.all(:conditions => [ "airdate LIKE ?", "#{y}%" ], 
             :order => order)
  end

end
