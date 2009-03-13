require 'sinatra'
require 'rack/cache'

#set :environment, :production
disable :run, :reload

require 'lib/asot'
run Sinatra::Application

