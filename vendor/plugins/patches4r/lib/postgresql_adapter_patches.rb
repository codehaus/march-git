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

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def change_column(table_name, column_name, type, options = {})
        native_type = native_database_types[type]
        
        # DEAL WITH TYPE
        sql_commands = ["ALTER TABLE #{table_name} ALTER #{column_name} TYPE #{type_to_sql(type, options[:limit])}"]
        
        # DEAL WITH DEFAULT
        if options[:default] == nil
          sql_commands << "ALTER TABLE #{table_name} ALTER #{column_name} DROP DEFAULT"
        else
          if options[:default] == 'now()'
            sql_commands << "ALTER TABLE #{table_name} ALTER #{column_name} SET DEFAULT now()"
          else
            sql_commands << "ALTER TABLE #{table_name} ALTER #{column_name} SET DEFAULT '#{options[:default]}'"
          end
        end
        
        # DEAL WITH NULLABILITY
        if options.has_key?(:null) and options[:null] == true
          sql_commands << "ALTER TABLE #{table_name} ALTER #{column_name} DROP NOT NULL"
        else
          sql_commands << "ALTER TABLE #{table_name} ALTER #{column_name} SET NOT NULL"
        end
        
        sql_commands.each { |cmd| 
          puts(cmd)
          execute(cmd) 
        }
      end
    end
  end
end