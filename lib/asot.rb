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
    last_modified(Asot.last_update)

    @is_admin = false
    do_it()
    erb :index
  end
end

get "/admin" do
    use Rack::Auth::Basic do |username, password|
      username == 'admin' && password == 'secret'
    end

    @is_admin = true
    do_it()
    erb :index
end

post "/update_note" do
  asot = Asot.find_by_no(params[:element_id].to_i)
  asot.notes = params[:update_value]
  asot.save!
end


def do_it
  @last_update = Asot.last_update
  @top_ten = Asot.all(:order => 'votes DESC', :limit => 10)

  @order = 'airdate DESC'
  @order = 'votes DESC' if request.path_info == '/by-rank'

  @episodes = {}
  @top5 = {}
  Asot::YEARS.each do |y|
    @episodes[y] = Asot.find_by_year(y, @order)

    top5 = Asot.find_by_year(y, 'votes DESC')[0..4]
    @top5[y] = top5.sort_by{|a| a.no} if top5.length == 5
  end

  Asot.calc_ranks
end
