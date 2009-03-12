namespace :cache do

  desc "Create tmp/cache/rack/[meta|body] directories"
  task :mkdir do
    `mkdir -p tmp/cache/rack/meta`
    `mkdir -p tmp/cache/rack/body`
  end
  
  desc "rm tmp/cache/rack/[meta|body] directories"
  task :sweep do
    `rm -r tmp/cache/rack/meta`
    `rm -r tmp/cache/rack/body`
  end
end

