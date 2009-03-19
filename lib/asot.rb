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
    response['Cache-Control'] = 'public, max-age=120'
    @last_update = Asot.last_update
    last_modified @last_update

    @top_ten = Asot.all(:order => 'votes DESC', :limit => 10)

    @order = 'airdate DESC'
    @order = 'votes DESC' if request.path_info == '/by-rank'

    @episodes = {}
    Asot::YEARS.each do |y|
      @episodes[y] = Asot.find_by_year(y, @order)
    end

    erb :index
  end
end

