namespace :images do

desc "Create Votes-for-Year SVG. Current year only."
task :votes_by_year_svg => :environment do
  y = Asot::YEARS.last
  Asot.draw_year_points_graph(y) if Asot.find_by_year(y).size > 5
end

desc "Create Votes-for-Year SVGs."
task 'votes_by_year_svg:all' => :environment do
  Asot::YEARS.each{ |y|
   Asot.draw_year_points_graph(y) if Asot.find_by_year(y).size > 5
}
end

desc "Convert vote SVGs to PNGs. Current year only."
task :votes_by_year_png => [:votes_by_year_svg] do
  y = Asot::YEARS.last
  svg = "public/images/votes_#{y}.svg"
  png = "public/images/votes_#{y}.png"

  if Asot.find_by_year(y).size > 5
    puts "Creating #{png}"
    `convert #{svg} #{png}`  # via ImageMagick
  end
end

desc "Convert vote SVGs to PNGs."
task 'votes_by_year_png:all' => ['votes_by_year_svg:all'] do
  Asot::YEARS.each{ |y|
     svg = "public/images/votes_#{y}.svg"
     png = "public/images/votes_#{y}.png"

     if Asot.find_by_year(y).size > 5
       puts "Creating #{png}"
       `convert #{svg} #{png}`  # via ImageMagick
     end
  }
end

task 'create'     => ['votes_by_year_png',      :smushit]
task 'create:all' => ['votes_by_year_png:all',  :smushit]
end

