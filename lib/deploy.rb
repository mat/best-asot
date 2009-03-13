set :application, "best-asot"
 
set :scm, :git
 
# set :local_repository, "git@github.com:[your_username]/[your_repo].git"
set :repository, "git://github.com/mat/best-asot.git" 
set :branch, "master"

set :deploy_to, "/home/mat/www/#{application}"
# set :deploy_via, :remote_cache # quicker checkouts from github

server "better-idea.org", :app, :web, :db, :primary => true 
 
namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru -e production start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru -e production stop"
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

namespace :images do
  desc "rake images:create"
  task :create do
    run "cd #{current_path} && rake RAILS_ENV=production images:create"
  end
end

after :deploy, "images:create"

