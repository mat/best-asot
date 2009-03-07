#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'activerecord'

require 'lib/models'
require 'lib/helpers'

#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile =>  'db/development.sqlite3'
)

set :views,  File.expand_path(File.join(File.dirname(__FILE__),'..','views'))
set :public,  File.expand_path(File.join(File.dirname(__FILE__),'..','public'))

#Sinatra::Application.default_options.merge!(
  #:views => File.join(ROOT_DIR, '..', 'views')
  #:app_file => File.join(ROOT_DIR, 'drewolson.rb'),
  #:run => false
#) 

get '/' do
    @by_votes      = Asot.all(:order => 'votes DESC', :limit => 10)
    @order         = 'airdate DESC'

    @episodes_2009 = Asot.find_by_year(2009, @order)
    @episodes_2008 = Asot.find_by_year(2008, @order)
    @episodes_2007 = Asot.find_by_year(2007, @order)
    @episodes_2006 = Asot.find_by_year(2006, @order)

    @last_update   = Asot.last_update

    erb :index
end

get '/by-rank' do
    @by_votes      = Asot.all(:order => 'votes DESC', :limit => 10)
    @order         = 'votes DESC'

    @episodes_2009 = Asot.find_by_year(2009, @order)
    @episodes_2008 = Asot.find_by_year(2008, @order)
    @episodes_2007 = Asot.find_by_year(2007, @order)
    @episodes_2006 = Asot.find_by_year(2006, @order)

    @last_update   = Asot.last_update

    erb :index
end
