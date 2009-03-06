class AsotController < ApplicationController
  caches_page :index

  def index
    @by_votes      = Asot.all(:order => 'votes DESC', :limit => 10)
    @order         = params[:order]

    @episodes_2009 = Asot.find_by_year(2009, @order)
    @episodes_2008 = Asot.find_by_year(2008, @order)
    @episodes_2007 = Asot.find_by_year(2007, @order)
    @episodes_2006 = Asot.find_by_year(2006, @order)

    @last_update   = Asot.last_update
  end
end
