set :application, "github-projects"
set :repository,  "git@github.com:thrivesmart/github-projects-tsapp.git"

set :user, "app"
set :use_sudo, false

set :deploy_to, "/var/www/apps/#{application}"
set :scm, :git
set :git_enable_submodules, 1

set :port, 33333
set :location, "209.20.86.103"
role :app, location
role :web, location
role :db,  location, :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Make symlink for database.yml" 
  task :symlink_dbyaml do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
  
  desc "Create empty database.yml in shared path" 
  task :create_dbyaml do
    run "mkdir -p #{shared_path}/config" 
    put '', "#{shared_path}/config/database.yml" 
  end
  
  desc "Make symlink for backup_fu.yml" 
  task :symlink_backupfu_yaml do
    run "ln -nfs #{shared_path}/config/backup_fu.yml #{release_path}/config/backup_fu.yml" 
  end
  
  desc "Create empty backup_fu.yml in shared path" 
  task :create_backupfu_yaml do
    run "mkdir -p #{shared_path}/config" 
    put '', "#{shared_path}/config/backup_fu.yml" 
  end


  desc "Make symlink for tsapp.yml"
  task :symlink_tsapp_yaml do
    run "ln -nfs #{shared_path}/config/tsapp.yml #{release_path}/config/tsapp.yml" 
  end
  
  desc "Create empty tsapp.yml in shared path" 
  task :create_tsapp_yaml do
    run "mkdir -p #{shared_path}/config" 
    put '', "#{shared_path}/config/tsapp.yml" 
  end
  
end

after 'deploy:setup', 'deploy:create_dbyaml'
after 'deploy:update_code', 'deploy:symlink_dbyaml'

after 'deploy:setup', 'deploy:create_backupfu_yaml'
after 'deploy:update_code', 'deploy:symlink_backupfu_yaml'

after 'deploy:setup', 'deploy:create_tsapp_yaml'
after 'deploy:update_code', 'deploy:symlink_tsapp_yaml'


after "deploy", "deploy:cleanup"