class AsotController < ApplicationController
  def index
    @by_votes   = Asot.all(:order => 'votes DESC', :limit => 10)

    @episodes_2008 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2008}
    @episodes_2007 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2007}
    @episodes_2006 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2006}

    @last_update = Asot.last_update
  end

end
