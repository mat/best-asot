require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'activerecord'

desc "Connect to database"
task :environment do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  'db/test.sqlite3'
  )
end


Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

