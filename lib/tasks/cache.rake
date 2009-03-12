namespace :cache do

  desc "Create tmp/cache/rack/[meta|body] directories"
  task :mkdir do
    `mkdir -p tmp/cache/rack/meta`
    `mkdir -p tmp/cache/rack/body`
  end
  
end

