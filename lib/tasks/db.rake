namespace :db do

  desc "Vacuum the sqlite3 database."
  task :vacuum => :environment do
    ActiveRecord::Base.connection.execute('VACUUM;')
  end
  
  desc "Tidy the database."
  task :tidy => [:vacuum] do
    #nothing
  end

  desc "Add Episode via di.fm URL and save to db."
  task :add_episode_via_url => :environment do
    raise 'Provide di.fm URL to rake task via url=DIFMURL' unless ENV['url']
    puts Asot.add_by_url_and_fetch ENV['url']
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
    a = Asot.last
    a.votes = Asot.fetch_di_votes(a.url)
    if a.votes_changed? && a.votes_was < a.votes
      a.save!
      RAILS_DEFAULT_LOGGER.info("ASOT #{a.no} UPDATED to #{a.votes}.")
    else
      RAILS_DEFAULT_LOGGER.info("ASOT #{a.no} remains unchanged at #{a.votes}.")
    end
    RAILS_DEFAULT_LOGGER.flush if RAILS_DEFAULT_LOGGER.respond_to?(:flush)
  end

  desc "Add Episode dummy for today."
  task :add_episode_for_today => :environment do
    a = Asot.new
    a.url = ''
    a.no  = Asot.last.no + 1
    a.airdate = Date.today
    a.save!
  end

  desc "Sets latest ASOTs url to currently playing song on di.fm."
  task :set_playing_track_url => :environment do
    a = Asot.last
    unless a.url.to_s =~ /forums.di.fm/
      a.url = Asot.fetch_di_playing_track
      a.save!
    end
  end

  desc "Migrate the database"
    task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end

  desc "Follow 301 Moved Permanently and save new url."
  task :follow_redirect_urls => :environment do
    asots_with_wrong_urls = Asot.all.find_all{ |a| a.url.include?('showthread.php') }
    asots_with_wrong_urls.each do |a|
      puts "old: #{a.url}"
      new_url = `curl -I #{a.url} | grep Location | awk '{print $2}'`
      a.url = new_url.strip
      a.save!
    end
  end

  desc "Dump asots as CSV to stdout."
  task(:dump_csv => :environment) do
    puts "id;no;url;votes;created_at;updated_at;airdate;notes"
    Asot.all.each do |asot|
      puts asot.to_csv
    end
  end

end
