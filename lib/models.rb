require 'activerecord'

class Asot < ActiveRecord::Base
  validates_presence_of :no
  validates_uniqueness_of :no
  validates_uniqueness_of :url, :allow_nil => true
  validates_uniqueness_of :airdate, :allow_nil => true
  validates_numericality_of :no
  validates_numericality_of :votes

  YEARS = (2006..Time.now.year).to_a

  # TODO Calculate ranks in SQL should we ever depart from sqlite.
  def rank
    raise 'Call Asot.calc_ranks first!' unless defined?(@@ranks) && @@ranks
    @@ranks[self.no]
  end

  def yearrank
    raise 'Call Asot.calc_ranks first!' unless defined?(@@yearranks) && @@yearranks
    @@yearranks[self.no]
  end

  def Asot.calc_ranks
    @@ranks = {}
    Asot.all(:order => 'votes DESC').each_with_index{ |asot,idx|
      @@ranks[asot.no] = idx + 1
    }

    @@yearranks = {}
    YEARS.each do |y|
      Asot.find_by_year(y, 'votes DESC').each_with_index{ |asot,idx|
        @@yearranks[asot.no] = idx + 1
      }
    end
  end

  def Asot.fetch_di_votes(di_forums_uri)
    require 'hpricot'
    require 'open-uri'
    xpath = "/html/body/div[1]/div/div/table[4]/tr[2]/td[3]/strong/a"
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
    Asot.all(:order => order).select{|a| a.airdate.year == y}
  end

  def to_csv
    require 'fastercsv'
    format = '%Y-%m-%d %H:%M:%S'
    cols = [self.id,
            self.no,
            self.url,
            self.votes,
            self.created_at.strftime(format),
            self.updated_at.strftime(format),
            self.airdate.strftime(format),
            self.notes]
    FasterCSV::generate_line(cols, :col_sep => ";")
  end

end
