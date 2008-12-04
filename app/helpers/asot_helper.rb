module AsotHelper
  def by_votes?
    @order.index('votes')
  end

  def by_airdate?
    @order.index('airdate')
  end
end
