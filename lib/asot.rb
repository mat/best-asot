#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'activerecord'

require 'lib/models'

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



      def partial(template, *args)
        options = args.extract_options!
        options.merge!(:layout => false)
        path = template.to_s.split(File::SEPARATOR)
        object = path[-1].to_sym
        path[-1] = "_#{path[-1]}"
        template = File.join(path).to_sym
        if collection = options.delete(:collection)
          collection.inject([]) do |buffer, member|
              buffer << erb(template, options.merge(:layout => false, :locals => {object => member}))
          end.join("\n")
        else
          erb(template, options)
        end
end

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

