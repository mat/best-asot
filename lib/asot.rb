#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'activerecord'

require 'lib/config'
require 'lib/models'
require 'lib/helpers'

#Sinatra::Application.default_options.merge!(
  #:views => File.join(ROOT_DIR, '..', 'views')
  #:app_file => File.join(ROOT_DIR, 'drewolson.rb'),
  #:run => false
#) 

["/", "/by-rank"].each do |path|
  get path do
    @last_update = Asot.last_update
    last_modified @last_update

    @by_votes = Asot.all(:order => 'votes DESC', :limit => 10)

    @order = 'airdate DESC'
    @order = 'votes DESC' if request.path_info == '/by-rank'

    @episodes_2009 = Asot.find_by_year(2009, @order)
    @episodes_2008 = Asot.find_by_year(2008, @order)
    @episodes_2007 = Asot.find_by_year(2007, @order)
    @episodes_2006 = Asot.find_by_year(2006, @order)

    erb :index
  end
end

