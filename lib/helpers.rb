helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def by_votes? ; @order.index('votes') ; end
  def by_airdate? ; @order.index('airdate') ; end

  def format_airdate(asot)
    unless asot.airdate.today?
      return "<td>#{asot.airdate.strftime("%d-%b-%Y")}</td>"
    end

    if (10..19).include? Time.now.hour 
     asot.url = h 'http://www.di.fm/calendar/calendar.php?type=day&calendar=2'
     return "<td class='onair'><a href='#{asot.url}'>Coming soon</a></td>"
    elsif (20..21).include? Time.now.hour 
     return "<td class='onair'><a href='#{asot.url}'>On air!</a></td>"
    else
     return "<td>#{asot.airdate.strftime("%d-%b-%Y")}</td>"
    end
  end

  def partial(template, *args)
    options = args.extract_options!
    options.merge!(:layout => false)
    path = template.to_s.split(File::SEPARATOR)
    object = path[-1].to_sym
    path[-1] = "_#{path[-1]}"
    template = File.join(path).to_sym
    if collection = options.delete(:collection)
      collection.inject([]) do |buffer, member|
        buffer << erb(template, options.merge(:layout => false, :locals => {object => member}))
      end.join("\n")
    else
      erb(template, options)
    end
  end
end

