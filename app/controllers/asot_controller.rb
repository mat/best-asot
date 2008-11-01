class AsotController < ApplicationController
  def index
    @by_votes   = Asot.all(:order => 'votes DESC')
    @latest     = Asot.all(:order => 'no DESC', :limit => 3)
    @all_asots  = Asot.all(:order => 'no DESC')
  end

end
