class Asot < ActiveRecord::Base

  validates_presence_of :no
  validates_uniqueness_of :no
  validates_uniqueness_of :url, :allow_nil => true
  validates_uniqueness_of :airdate, :allow_nil => true

  def rank
    @by_votes   = Asot.all(:order => 'votes DESC')
    @by_votes.find_index(self) + 1
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
   episodes          = Asot.all.find_all{|a| a.airdate && a.airdate.year == for_year}
   episodes_by_date  = episodes.map{|a| [a.airdate, a.no, a.votes] }.sort
   episode_and_votes = episodes_by_date.map{|date_no_votes| date_no_votes[1..2]}
   episode_and_votes
  end

  def Asot.draw_year_points_graph(for_year = Time.now.year)
   require 'scruffy'

   markers, data = Asot.episode_and_votes(for_year).transpose

   graph = Scruffy::Graph.new
   graph.title = "ASOT Episodes #{for_year}"
   graph.renderer = Scruffy::Renderers::Standard.new

   # marker just for top 3 votes
   top_votes = data.sort[-3..-1]
   data.each_with_index do |vote, i|
     markers[i] = nil unless top_votes.include?(vote)
   end
   graph.point_markers = markers
   
   graph.add :bar, "Votes", data
   graph.render :width => 600, :to => "votes_#{for_year}.svg"
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
end
