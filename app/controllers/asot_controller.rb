class AsotController < ApplicationController
  def index
    @top        = Asot.all(:order => 'votes DESC', :limit => 10)
    @latest     = Asot.all(:order => 'no DESC', :limit => 3)
    @all_asots  = Asot.all(:order => 'no DESC')
  end

end
