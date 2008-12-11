namespace :db do

  desc "Writes notes from db/special_asots.csv to db."
  task :write_notes => :environment do
    puts Asot.write_notes(FasterCSV.parse(IO.read('db/special_asots.csv'), :col_sep => ';'))
  end

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
    if a.changed?
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

end
