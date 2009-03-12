require 'sinatra'
require 'rack/cache'

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/home/mat/repos/git/best-asot/tmp/cache/rack/meta',
  :entitystore => 'file:/home/mat/repos/git/best-asot/tmp/cache/rack/body'
 
set :environment, :production
disable :run, :reload

require 'lib/asot'
run Sinatra::Application

