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

