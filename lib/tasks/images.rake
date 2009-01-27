YEARS = (2006..2009).to_a

namespace :images do

desc "Create Votes-for-Year SVGs."
task :votes_by_year_svg => :environment do
  YEARS.each{ |y|
   Asot.draw_year_points_graph(y) if Asot.find_by_year(y).size > 5
}
end

desc "Convert vote SVGs to PNGs."
task :votes_by_year_png => [:votes_by_year_svg] do
  YEARS.each{ |y|
     svg = "public/images/votes_#{y}.svg"
     png = "public/images/votes_#{y}.png"

     if Asot.find_by_year(y).size > 5
       puts "Creating #{png}"
       `convert #{svg} #{png}`  # via ImageMagick
     end
  }
end

task :create => [:votes_by_year_png, :smushit]
end

