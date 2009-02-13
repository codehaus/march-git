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

class DatabaseFunction
  
  def self.install(function)
    puts "Installing #{function}"
    sql = IO.readlines("#{source_path}/#{function}.sql")
    sql = sql.join('')
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.uninstall(function)
    puts "Uninstalling #{function}"
    ActiveRecord::Base.connection.execute("DROP FUNCTION #{function}")
  end
  
  def self.install_all
    Dir.glob("#{source_path}/*.sql").each { |path|
      puts "Installing #{path}"
      if path =~ /db\/functions\/(trg_.*).sql$/
        install($1)
        next
      end
      if path =~ /db\/functions\/(sp_.*).sql$/
        install($1)
        next
      end
    }
  end
  
  def self.exec(function)
    puts "Running #{function}"
    start = Time.new
    ActiveRecord::Base.connection.execute("SELECT #{function}")
    finish = Time.new
    
    puts "Complete (#{finish - start}s)"
  end
  
private
  def self.source_path()
    return "#{RAILS_ROOT}/db/functions"
  end
end