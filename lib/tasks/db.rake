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
    RAILS_DEFAULT_LOGGER.flush
  end

  desc "Add Episode dummy for today."
  task :add_episode_for_today => :environment do
    a = Asot.new
    a.url = ''
    a.no  = Asot.last.no + 1
    a.airdate = Time.today
    a.save!
  end

  desc "Sets latest ASOTs url to currently playing song on di.fm."
  task :set_playing_track_url => :environment do
    a = Asot.last
    a.url = Asot.fetch_di_playing_track
    a.save!
  end

  desc "Migrate the database"
    task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

