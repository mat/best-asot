
configure :development do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  'db/development.sqlite3'
  )
end

configure :production do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  'db/production.sqlite3'
  )
end

configure :test do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  'db/test.sqlite3'
  )
end

configure do
  set :views,   File.expand_path(File.join(File.dirname(__FILE__),'..','views'))
  set :public,  File.expand_path(File.join(File.dirname(__FILE__),'..','public'))
end

