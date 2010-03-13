require 'sinatra'
require 'rack/cache'
require 'rack'
require 'rack/contrib'

#use Rack::Profiler, :printer => :graph_html, :times => 5 #if ENV['RACK_ENV'] == 'development'

set :environment, :production
disable :run, :reload

require 'lib/asot'
run Sinatra::Application

