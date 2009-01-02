YEARS = (2006..2009).to_a

desc "Create Votes-for-Year SVGs."
task :votes_by_year_svg => :environment do
  YEARS.each{ |y|
   Asot.draw_year_points_graph(y) if Asot.find_by_year(y).size > 5
}
end

desc "Convert vote SVGs to PNGs."
task :votes_by_year_png => [:votes_by_year_svg] do
  YEARS.each{ |y|
     # via ImageMagick
    `convert public/images/votes_#{y}.svg public/images/votes_#{y}.png` if Asot.find_by_year(y).size > 5

  }
end

