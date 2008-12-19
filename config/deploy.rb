set :application, "best-asot"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/mat/www/#{application}"

set :use_sudo, false

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :repository, "git://github.com/mat/best-asot.git"
set :branch, "master"

server "better-idea.org", :app, :web, :db, :primary => true

desc "A setup task to put shared system, log, and database directories in place"
task :setup, :roles => [:app, :db, :web] do
run <<-CMD
mkdir -p -m 775 #{release_path} #{shared_path}/system #{shared_path}/db &&
mkdir -p -m 777 #{shared_path}/log
CMD
end


namespace :cache do
  desc "rake cache:sweep"
  task :sweep do
    run "cd #{current_path} && rake cache:sweep"
  end
end

desc "rake votes_by_year_png"
task :votes_by_year_png do
  run "cd #{current_path} && rake RAILS_ENV=production votes_by_year_png"
end

after :deploy, "cache:sweep", "votes_by_year_png"

