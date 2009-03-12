require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'activerecord'
require 'lib/models'

RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)

desc "Connect to database"
task :environment do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  "db/#{ENV["RAILS_ENV"] || "development"}.sqlite3"
  )
end


Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

