set :application, "best-asot"
 
set :scm, :git
 
# set :local_repository, "git@github.com:[your_username]/[your_repo].git"
set :repository, "git://github.com/mat/best-asot.git" 
set :branch, "master"

set :deploy_to, "/home/mat/www/#{application}"
# set :deploy_via, :remote_cache # quicker checkouts from github

server "better-idea.org", :app, :web, :db, :primary => true 

depend :remote, :file, "#{shared_path}/config/config.rb"
 
namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R config.ru start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

after "deploy:symlink", :symlink_shared

task :symlink_shared do
  run("ln -s #{shared_path}/config/config.rb #{current_path}/lib/config.rb")
end
