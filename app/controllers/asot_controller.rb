class AsotController < ApplicationController
  caches_page :index

  def index
    @by_votes   = Asot.all(:order => 'votes DESC', :limit => 10)

    #Asot.find_by_year(2007)

    @episodes_2008 = Asot.find_by_year(2008)
    @episodes_2007 = Asot.find_by_year(2007)
    @episodes_2006 = Asot.find_by_year(2006)

    @last_update = Asot.last_update
  end

end
