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

def import()
  config   = ActiveRecord::Base.configurations[RAILS_ENV]

  if ( RAILS_ENV == 'production' )
    puts "sorry, that's too dumb" 
    return
  end
  
  if not File.directory?("tmp/archive")
    system("cd tmp;tar xzvf ../test/archive.tar.gz")
  end
  system("./script/import-ezmlm-archive-messages ./tmp/archive")
end

desc 'Loads some test messages into the local instance'
task :import  => [:environment] do |t|
  import
end
