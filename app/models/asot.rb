class Asot < ActiveRecord::Base

  validates_presence_of :no
  validates_uniqueness_of :no
  validates_uniqueness_of :di_url


  def Asot.fetch_di_uri(episode_number)
    # Let's emulate
    #  curl -e http://better-idea.org 'http://ajax.googleapis.com/'
    #  'ajax/services/search/web?v=1.0&'
    #  'q=%22a+state+of+trance+episode+369%22+site%3Aforums.di.fm%2Ftrance'

    header = { 'Referer' => "http://better-idea.org" } 

    res = Net::HTTP.start('ajax.googleapis.com') { |http|
      http.get("/ajax/services/search/web?v=1.0&q=%22a+state+of+trance+episode+#{episode_number}%22+site:forums.di.fm/trance", header)
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

  def Asot.fetch_asots(episodes)

    problems = []
    episodes.each { |ep| 
      a = Asot.new 
      a.no=ep; 
      print "Fetching ep #{ep}... "
      begin
      a.di_url   = Asot.fetch_di_uri(ep) 
      a.di_votes = Asot.fetch_di_votes(a.di_url)
      a.save!
      puts "ok"
      rescue Exception => e
        puts "FAILED #{e}"
        problems << ep
      end
    }
    problems
  end
end
