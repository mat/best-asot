require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'mongo_mapper'
require 'lib/models'

RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)

desc "Connect to database"
task :environment do

  # TODO Solve this dupolication nonsense.
  dbname = case ENV["RAILS_ENV"]
            when 'production' : 'bestasot'
            when 'test'       : 'bestasottest'
            else                'bestasotdev'
           end

  MongoMapper.database = dbname
end


Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

