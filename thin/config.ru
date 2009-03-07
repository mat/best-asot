require 'sinatra'
 
set :environment, :production
disable :run, :reload

require 'lib/asot'
run Sinatra::Application

