require "rubygems"
require "bundler"
Bundler.setup

require 'sinatra'
require 'rack/cache'
require 'rack'
require 'rack/contrib'

#use Rack::Profiler, :printer => :graph_html, :times => 5 #if ENV['RACK_ENV'] == 'development'

set :environment, :production
disable :run, :reload

require "rack/version_header"

use Rack::VersionHeader,
  :header_name  => 'X-Git-Revision',
  :version_file => '.gitrevision'

require 'lib/asot'
run Sinatra::Application

