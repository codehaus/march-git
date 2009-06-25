################################################################################
#  Copyright 2006-2009 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################
require 'lib/backup_db.rb'

#I couldn't get require or include to work properly, so I'll just eval it in-place
if not ENV['CUSTOMER']
  raise Exception.new("You must specify a customer using the CUSTOMER=<customer key> notation")
end

customer = ENV['CUSTOMER'].strip.downcase
set :customer, customer

deploy_rb = File.dirname(__FILE__) + "/customer/#{customer}/deploy.rb"
if not File.exist?(deploy_rb)
  raise Exception.new("No customer specific deploy.rb found: #{deploy_rb}")
end

eval(IO.read(deploy_rb))

puts "Deploying to #{customer}"

# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "march"

# Repository options
set :scm, "git"
set :git_enable_submodules, 1
set :repository,  "git://git.codehaus.org/march-git.git"
set :repository_site, "file:///opt/march/site.git"
set :branch, "master"

ssh_options[:user] = 'ror-march'
ssh_options[:forward_agent] = true


# =============================================================================
# REPOSITORY VARIABLES
# =============================================================================
set :deploy_to, '/opt/march'
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'ror-march'
#ssh_options[:user] = 'ror-march'



task :after_update_code do
  run <<-CMD
    rm -rf #{shared_path}/site &&
    git clone #{repository_site} #{shared_path}/site &&
    rm -rf #{release_path}/site &&
    ln -nfs #{shared_path}/site #{release_path}/site
  CMD
  puts "Site specific configuration connected"

  run <<-CMD
    rm -rf #{release_path}/tmp &&
    ln -nfs #{shared_path}/tmp #{release_path}/tmp &&
    mkdir -p #{shared_path}/tmp/sessions
  CMD
  puts "Links updated"
  
  run <<-CMD
    mkdir -p #{shared_path}/sitemap &&
    rm -rf #{release_path}/public/sitemap* &&
    ln -nfs #{shared_path}/sitemap/sitemap* #{release_path}/public/
  CMD
  puts "Links updated"

end


namespace :deploy do
  task :restart, :roles => :web do
    #Restart Passenger configured sites
    run "touch #{current_path}/tmp/restart.txt"
    stop_backgroundrb #daemontools will restart it
  end
end



desc "Stop the backgroundrb server"
task :stop_backgroundrb , :roles => :app do
  run "cd #{current_path} && ./script/backgroundrb/stop"
end