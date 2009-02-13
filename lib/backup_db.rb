################################################################################
#  Copyright 2007-2008 Codehaus Foundation
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

require 'fileutils'

Capistrano.configuration(:must_exist).load do
  
  desc 'Backup database'
  task :backup_db, :roles => [ :db ] do
    date = Time.now.strftime("%Y%m%d%H%M%S")
    sourceuser = "march_production_owner"
    sourcedb = "march_production"
    dbdumpdir = "#{shared_path}/backups"
    dbdump = "#{dbdumpdir}/#{sourcedb}_#{date}.txt.bz"
    
    
    logger.info { "Dumping #{sourcedb} into #{dbdump}" }
    
    run <<-CMD
      mkdir -p #{dbdumpdir} &&
      pg_dump -U #{sourceuser} -O -x #{sourcedb} | bzip2 -9 > #{dbdump}
    CMD
    
    logger.info { "Complete." }
    
  end
  
end
  