################################################################################
#  Copyright (c) 2004-2007, by OpenXource, LLC. All rights reserved.           #
#
#  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF OPENXOURCE                   #
#
#  The copyright notice above does not evidence any                            #
#  actual or intended publication of such source code.                         #
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
set :repository, "https://svn.rubyhaus.org/march/trunk"
set :repository_site, "file:///opt/march/svn/trunk"

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
# set :deploy_to, "/path/to/app" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway
set :deploy_to, '/opt/march'
set :deploy_via, :remote_cache
set :mongrel_conf, "#{deploy_to}/current/config/mongrel/mongrel_cluster.yml"
set :mongrel_user, 'ror-march'
set :mongrel_group, 'ror-march'
set :use_sudo, false
set :user, 'ror-march'
#ssh_options[:user] = 'ror-march'


# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25
# ssh_options[:verbose] = :debug

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

task :after_update_code do
  run <<-CMD
    svn --non-interactive co #{repository_site} #{shared_path}/site &&
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
end

namespace :deploy do
  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        #invoke_command checks the use_sudo variable to determine how to run the mongrel_rails command
        mongrel_conf = "/opt/march/current/site/config/mongrel"
        invoke_command "mongrel_cluster_ctl #{t.to_s} -c #{mongrel_conf}", :via => run_method
      end
      
      task :reset, :roles => :app do
        run "rm -f /opt/march/current/log/mongrel.*.pid"
      end
    end
  end

  desc "Custom restart task for mongrel cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.mongrel.restart
  end

  desc "Custom start task for mongrel cluster"
  task :start, :roles => :app do
    deploy.mongrel.start
  end

  desc "Custom stop task for mongrel cluster"
  task :stop, :roles => :app do
    deploy.mongrel.stop
  end

  desc "Custom reset task for mongrel cluster"
  task :reset, :roles => :app do
    deploy.mongrel.reset
  end
  
  task :before_restart, :roles => :web do
    warning = "March is currently restarting... please wait..."
    put warning, "/opt/march/shared/system/maintenance.html"
    run "chmod 644 /opt/march/shared/system/maintenance.html" 
  end

  task :after_restart, :roles => :web do
    run "rm -f /opt/march/shared/system/maintenance.html"
  end

end