require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'activerecord'
require 'lib/models'

RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)

desc "Connect to database"
task :environment do

  # TODO Solve this dupolication nonsense.
  dbfile = case ENV["RAILS_ENV"]
            when 'production' : '/home/mat/www/best-asot/shared/db/production.sqlite3'
            when 'test'       : 'db/test.sqlite3'
            else                'db/development.sqlite3'
           end

  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database =>  dbfile
  )
end


Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

