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

    if (20..21).include? Time.now.hour 
      return "<td class='onair'><a href='#{asot.url}'>On air!</a></td>"
    end
  end
end
