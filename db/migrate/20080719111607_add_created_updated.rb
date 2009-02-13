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

class AddCreatedUpdated < ActiveRecord::Migration
  def self.up
    for table in ActiveRecord::Base.connection.tables
      next if [ 'schema_info'].include?(table)
      
      add_the_column(table, :created_at)
      add_the_column(table, :updated_at)
    end
  end

  def self.down
    raise IrreversibleMigrationException.new("Remove the timestamps fields for yourself!")
  end
  
  def self.has_column?(table, column_name)
    for column in ActiveRecord::Base.connection.columns(table)
      return true if column.name == column_name.to_s
    end
    return false
  end
  
  def self.add_the_column(table, column)
    if not has_column?(table, column)
      puts " Adding #{table}.#{column}"
      add_column table.to_sym, column.to_sym, :timestamptz, :null => true
    end
  end

end
