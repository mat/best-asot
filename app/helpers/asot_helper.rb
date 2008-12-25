module AsotHelper
  def by_votes?
    @order.index('votes')
  end

  def by_airdate?
    @order.index('airdate')
  end

  def format_airdate(asot)
    unless asot.airdate.today?
      return "<td>#{asot.airdate.strftime("%d-%b-%Y")}</td>"
    end
    

    if (10..19).include? Time.now.hour 
     asot.url = 'http://www.di.fm/calendar/calendar.php?type=day&calendar=2'
     return "<td class='onair'><a href='#{asot.url}' target='_blank'>Coming soon</a></td>"
    elsif (20..21).include? Time.now.hour 
     return "<td class='onair'><a href='#{asot.url}' target='_blank'>On air!</a></td>"
    else
     return "<td>#{asot.airdate.strftime("%d-%b-%Y")}</td>"
    end
  end
end
