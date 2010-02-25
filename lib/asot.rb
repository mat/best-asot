#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mongo_mapper'

require 'lib/config'
require 'lib/models'
require 'lib/helpers'

helpers do

  def protected!
    response['WWW-Authenticate'] = %(Basic realm="Best ASOT") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials \
    && @auth.credentials == [options.http_admin_user, options.http_admin_pass]
  end

end


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
  protected!

    @is_admin = true
    do_it()
    erb :index
end

post "/update_note" do
  protected!

  asot = Asot.find_by_no(params[:element_id].to_i)
  asot.notes = params[:update_value]
  asot.save!
end

post "/update_url" do
  protected!
  puts params

  asot = Asot.find_by_no(params[:element_id].to_i)
  asot.url = params[:update_value].to_s.strip
  asot.votes = Asot.fetch_di_votes(asot.url)
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
