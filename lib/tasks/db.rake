namespace :db do

  desc "Add Episode via di.fm URL and save to db."
  task :add_episode_via_url => :environment do
    raise 'Provide di.fm URL to rake task via url=DIFMURL' unless ENV['url']
    puts Asot.add_by_url_and_fetch(ENV['url'])
  end

  desc "Bulk add episodes via url file."
  task :add_episodes_from_file => :environment do
    raise 'Provide file name to rake task via urls=FILENAME' unless ENV['urls']
    IO.read(ENV['urls']).each_line do |url|
      begin
        puts Asot.add_by_url_and_fetch(url)
      rescue Exception => e
        puts url
        puts e
      end
    end
  end

  desc "Update latest ASOT's votes."
  task :update_latest_asot => :environment do
    a = Asot.last(:order => "no")
    a.votes = Asot.fetch_di_votes(a.url)
    unless a.votes_changed?
      puts "ASOT #{a.no} remains unchanged at #{a.votes}."
    else
      if a.votes > a.votes_was
        puts "ASOT #{a.no} had #{a.votes_was} votes, now has #{a.votes} votes."
        a.save!
      else
        puts "Huh? ASOT #{a.no} had #{a.votes_was} votes, now has #{a.votes} votes. Won't update."
      end
    end
  end

  desc "Add Episode dummy for today."
  task :add_episode_for_today => :environment do
    last_asot = Asot.last(:order => "no")
    a = Asot.new
    a.url = ''
    a.no  = last_asot.no + 1
    a.airdate = Time.now # cron at 10h
    a.votes = 0
    a.save!
  end

  desc "Sets latest ASOTs url to currently playing song on di.fm."
  task :set_playing_track_url => :environment do
    a = Asot.last(:order => "no")
    unless a.url.to_s =~ /forums.di.fm/
      a.url = Asot.fetch_di_playing_track
      a.save!
    end
  end

  desc "Inserts the song currently playing on di.fm."
  task :insert_asot_playing_right_now => :environment do
    di_url = Asot.fetch_di_playing_track
    di_url = url_after_redirection(di_url)
    a = Asot.add_by_url_and_fetch(di_url)
    puts "Added #{a.inspect}"
  end

  desc "Follow 301 Moved Permanently and save new url."
  task :follow_redirect_urls => :environment do
    asots_with_wrong_urls = Asot.all.find_all{ |a| a.url.to_s.include?('showthread.php') }
    asots_with_wrong_urls.each do |a|
      puts "old: #{a.url}"
      new_url = url_after_redirection(a.url)
      a.url = new_url.strip
      a.save!
    end
  end

  desc "Dump asots as CSV to stdout."
  task(:dump_csv => :environment) do
    puts "id;no;url;votes;created_at;updated_at;airdate;notes"
    Asot.all(:order => "no ASC").each do |asot|
      puts asot.to_csv
    end
  end

  desc "Import asots from csv file."
  task(:import_csv => :environment) do
    raise 'Provide file name via csv=FILENAME' unless ENV['csv']

    IO.read(ENV['csv']).each_line do |line|
      next if line.to_s.strip.empty?
      next if line.start_with?("id") # skip header
      begin
        puts Asot.from_csv(line).save!
      rescue Exception => e
        puts line
        puts e
      end
    end
  end

  desc "Load'n'save all asots" # to trigger before_save.
  task(:save_all_asots => :environment) do
    Asot.all.each{ |a| a.save!; puts a}
  end

  def url_after_redirection(url)
    new_url = `curl -I #{url} | grep Location | awk '{print $2}'`.chomp
  end

end
