configure do

#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile =>  'db/development.sqlite3'
)

set :views,  File.expand_path(File.join(File.dirname(__FILE__),'..','views'))
set :public,  File.expand_path(File.join(File.dirname(__FILE__),'..','public'))

end

