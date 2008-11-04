YEARS = (2006..2008).to_a

desc "Create Votes-for-Year SVGs."
task :votes_by_year_svg => :environment do
  YEARS.each{ |y| Asot.draw_year_points_graph(y) }
end

desc "Convert vote SVGs to PNGs."
task :votes_by_year_png => [:votes_by_year_svg] do
  YEARS.each{ |y|
     # via ImageMagick
    `convert public/images/votes_#{y}.svg public/images/votes_#{y}.png`
  }
end

