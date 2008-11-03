class AsotController < ApplicationController
  def index
    @by_votes   = Asot.all(:order => 'votes DESC')
    @latest     = Asot.all(:order => 'no DESC', :limit => 3)

    @top_2008   = Asot.all(:order => 'votes DESC').find_all{|a| a.airdate && a.airdate.year == 2008}
    @episodes_2008 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2008}

    @top_2007   = Asot.all(:order => 'votes DESC').find_all{|a| a.airdate && a.airdate.year == 2007}
    @episodes_2007 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2007}

    @top_2006   = Asot.all(:order => 'votes DESC').find_all{|a| a.airdate && a.airdate.year == 2006}
    @episodes_2006 = Asot.all(:order => 'no DESC').find_all{|a| a.airdate && a.airdate.year == 2006}
  end

end
