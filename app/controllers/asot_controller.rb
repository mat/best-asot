class AsotController < ApplicationController
  def index
    @top5 = Asot.all(:order => 'votes DESC', :limit => 10)
    @last5 = Asot.all(:order => 'no DESC', :limit => 3)
    @asots = Asot.all(:order => 'no DESC')
  end

end
