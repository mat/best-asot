
configure :development do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  'db/development.sqlite3'
  )
  use Rack::Cache,
    :verbose     => true,
    :metastore   => 'file:/home/mat/repos/git/best-asot/tmp/cache/rack/meta',
    :entitystore => 'file:/home/mat/repos/git/best-asot/tmp/cache/rack/body'
end

configure :production do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  '/home/mat/www/best-asot/shared/db/production.sqlite3'
  )
  use Rack::Cache,
    :verbose     => true,
    :metastore   => 'file:/home/mat/www/best-asot/shared/cache/rack/meta',
    :entitystore => 'file:/home/mat/www/best-asot/shared/cache/rack/body'
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

