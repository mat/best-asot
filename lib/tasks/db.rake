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

end

