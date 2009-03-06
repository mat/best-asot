class Asot < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  validates_presence_of :no
  validates_uniqueness_of :no
  validates_uniqueness_of :url, :allow_nil => true
  validates_uniqueness_of :airdate, :allow_nil => true

  def rank
    unless defined? @rank
      @by_votes = Asot.all(:order => 'votes DESC')
      @rank = @by_votes.index(self) + 1
    end
    @rank
  end

  def yearrank
    -1 if self.airdate.nil?
    unless defined? @yearrank
      @by_votes = Asot.find_by_year(airdate.year, 'votes DESC')
      @yearrank = @by_votes.index(self) + 1
    end
    @yearrank
  end

  def Asot.fetch_di_uri(episode_number)
    # Let's emulate
    #  curl -e http://better-idea.org 'http://ajax.googleapis.com/'
    #  'ajax/services/search/web?v=1.0&'
    #  'q=intitle%3A%22presents+-+a+state+of+trance+episode+369%22'
    #  '+site%3Aforums.di.fm%2Ftrance'

    header = { 'Referer' => "http://better-idea.org" } 

    res = Net::HTTP.start('ajax.googleapis.com') { |http|
      http.get("/ajax/services/search/web?v=1.0&q=intitle%3A%22a+state+of+trance+episode+#{episode_number}%22+site:forums.di.fm/trance", header)
    }

   # return first hit
   json = JSON.parse(res.body)
   json["responseData"]["results"].first['url'] 
  end

  def Asot.fetch_di_votes(di_forums_uri)
    xpath = "/html/body/div[1]/div/div/table[3]/tr[2]/td[3]/strong/a"
    doc = Hpricot(open(di_forums_uri))
    votes = doc.at(xpath).inner_html.to_i
  end

  def Asot.fetch_di_date(di_forums_uri)
    xpath = "/html/body/div[2]/div[1]/div/div/div/table/tr[1]/td[1]"
    doc = Hpricot(open(di_forums_uri))
    airdate = Time.parse(doc.at(xpath).inner_text.strip)
    airdate = Time.local(airdate.year, airdate.month, airdate.day)
  end

  def Asot.fetch_di_playing_track
    xpath = "/html/body/table/tr/td/table/tr[2]/td/table/tr/td[1]/table/tr[3]/td[2]/a[1]"
    doc = Hpricot(open('http://www.di.fm/trance/mini.html'))
    doc.at(xpath)['href']
  end

  def Asot.fetch_asots(episodes)

    problems = []
    episodes.each { |ep| 
      a = Asot.new 
      a.no=ep; 
      print "Fetching ep #{ep}... "
      begin
      a.url   = Asot.fetch_di_uri(ep) 
      a.votes = Asot.fetch_di_votes(a.url)
      a.save!
      puts "ok"
      rescue Exception => e
        puts "FAILED #{e}"
        problems << ep
      end
    }
    problems
  end

  def Asot.missing_asots
    episodes = Asot.all.map{|a| a.no}
    missing_episodes = []
    (episodes.min..episodes.max).each{ |e|
     missing_episodes << e unless Asot.find_by_no(e)
    }
    puts "Should have #{episodes.max - episodes.min + 1} episodes, #{missing_episodes.length} are missing:"
    missing_episodes
  end

  def Asot.fetch_airdates(asots = Asot.all)
    problems = []

    asots.each do |a|
      print "Fetching airdate #{a.no}... "
      begin
        if a.airdate.nil? && a.url
          a.airdate = fetch_di_date(a.url)
          a.save!
          puts 'fetched'
        else
          puts 'not possible/necessary'
        end
      rescue Exception => e
        puts "FAILED #{e}"
        problems << a.no
      end
    end
    problems
  end

  def Asot.remove_index_html_from_path(url)
    i = url.index(/\/index.*\.html/)
    return nil unless i
    url[0..i]
  end

  def Asot.tidy_urls(asots = Asot.all)
    count = 0
    asots.each do |a|
      tidy = Asot.remove_index_html_from_path a.url
      if tidy
        puts a.url
        puts tidy
        count += 1
        a.url = tidy
        a.save!
      end
    end
    count
  end

  def Asot.episode_and_votes(for_year=Time.now.year)
   episodes = Asot.all.find_all{|a| a.airdate && a.airdate.year == for_year}
   episodes_nos_and_votes = episodes.map{|a| [a.no, a.votes] }.sort
  end


  def Asot.draw_year_points_graph(for_year = Time.now.year)
   require 'scruffy'

   ep_nos, votes = Asot.episode_and_votes(for_year).transpose

   # highlight top episodes via different data points
   tops_shown = 5
   tops, titles = Asot.extract_top_episodes(votes, ep_nos, tops_shown)

   graph = Scruffy::Graph.new
   graph.title = "ASOT Episodes #{for_year}"
   graph.renderer = Scruffy::Renderers::Standard.new

   graph.add :bar, "", votes
   1.upto(tops_shown) do |i|
     graph.add :bar, titles[i-1], tops[i-1]
   end

   top_vote  = votes.sort.last
   graph.render :width => 450, 
                :min_value => 0,
                :max_value => ((top_vote + 20) / 20).floor * 20,
                :to => "public/images/votes_#{for_year}.svg"
   :ok
  end

  # rake db:write_notes
  def Asot.write_notes(csv_data)
    csv_data.each { |no,text| 
      a = Asot.find_by_no(no.to_i)
      a.notes = text
      a.save!
    }
    :ok
  end

  def Asot.check_url(no, url)
    url.index(no.to_s) != nil
  end

  def Asot.check_urls(asots = Asot.all(:order => 'no'))
    problems = []

    asots.each do |a|
      print "Checking url #{a.no}... "
      begin
        if a.url
         if Asot.check_url(a.no, a.url)
          puts 'ok'
         else
          puts 'ooooooops'
         end
        else
          puts 'no url'
        end
      rescue Exception => e
        puts "FAILED #{e}"
        problems << a.no
      end
    end
    problems
  end

  def Asot.date_is_thursday?(time)
    time.wday == 4
  end

  def Asot.airdate_infos
    Asot.all.map{|a| 
         [a.no, 
          a.airdate && a.airdate.strftime('%U'), 
          a.airdate && Asot.date_is_thursday?(a.airdate)]
    }.sort
  end

  def Asot.vote_histogram(width = 10, asots = Asot.all)
    hist = Hash.new { |h,k| h[k] = 0 }

    asots.each do |a|
      next if a.votes.nil?
      hist[a.votes / width] += 1
    end

    puts asots.length
    puts hist.values.inject(0){ |sum,n| sum += n}

    # Fill empty bins with 0
    0.upto(hist.keys.max-1) do |n|
      hist[n] += 0
    end

    hist.sort
  end

  def Asot.draw_vote_histogram(width=10)
   require 'scruffy'

   votes = Asot.vote_histogram(width).transpose.last

   graph = Scruffy::Graph.new
   graph.title = "Vote distribution"
   graph.renderer = Scruffy::Renderers::Standard.new
   graph.point_markers = Array.new(votes.length){nil}
   graph.point_markers[0] = 0
   graph.point_markers[1] = width * 1
   graph.point_markers[2] = width * 2
   graph.point_markers[3] = width * 3
   graph.point_markers[votes.length - 1] = width * (votes.length - 1)

   graph.add :bar, "Votes", votes

   graph.render :width => 600, 
                :min_value => 0,
               # :max_value => ((top_vote + 20) / 20).floor * 20,
                :to => "public/images/vote_hist.svg"
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
    Asot.last(:order => 'updated_at').updated_at
  end

  def Asot.find_by_year(y, order = 'airdate DESC')
    Asot.all(:conditions => [ "airdate LIKE ?", "#{y}%" ], 
             :order => order)
  end

  private

  def Asot.extract_top_episodes(votes, ep_nos, tops_shown = 5)
   top_votes  = votes.sort[-(tops_shown)..-1].reverse
   tops       = Array.new(tops_shown)
   tops_title = Array.new(tops_shown)

   1.upto(tops_shown) do |i|
     tops[i-1] = Array.new(votes.length){0}
     idx = votes.index(top_votes[i-1])
     tops[i-1][idx] = votes[idx]
     tops_title[i-1] = "##{ep_nos[idx]}"
   end

   [tops, tops_title]
  end
end
