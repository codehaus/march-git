################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

def db_command(user, pass, host, database, command)
  ENV['PGUSER'] = user
  ENV['PGPASSWORD'] = pass
  ENV['PGHOST'] = host
  ENV['PGDATABASE'] = database
  puts "Running: #{command}"
  `psql -c "#{command}"`
end

def freshdb()
  config   = ActiveRecord::Base.configurations[RAILS_ENV]

  if ( RAILS_ENV == 'production' )
    puts "sorry, that's too dangerous" 
    return
  end

  ActiveRecord::Base.connection.disconnect! if ActiveRecord::Base.connected?

  database = config['database']
  user     = config['username']
  password = config['password']

  ts = config['tablespace']
  ts_clause = ''

  if ( ! ts.nil? && ts != '' )
    ts_clause = " tablespace = #{ts}"
  end

  begin
    db_command(user, password, 'localhost', 'template1', "drop database #{database}")
  rescue Exception => e
    puts "drop database failed: #{e}"
  end
  
  db_command(user, password, 'localhost', 'template1', "create database #{database} #{ts_clause}")
end

task :pre_freshdb => [:environment] do |t|
  # intentionally left blank
end

task :post_freshdb => [:environment] do |t|
  # intentionally left blank
end

desc 'Create a fresh db'
task :freshdb => [:environment] do |t|
  Rake::Task['pre_freshdb'].invoke
  freshdb
  Rake::Task['post_freshdb'].invoke
end
