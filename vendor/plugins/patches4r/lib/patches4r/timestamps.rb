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

module Patches4R
  class Timestamps
    
    def self.migrate_add_trigger_functions
      puts "Creating trigger insert_timestamp_trigger"
      sql = <<EOF
      CREATE or REPLACE FUNCTION insert_timestamp_trigger()
      RETURNS "pg_catalog"."trigger" AS 
      $BODY$
      BEGIN
           NEW.insert_timestamp = CURRENT_TIMESTAMP;
           RETURN NEW;
      END;
      $BODY$
      LANGUAGE 'plpgsql' VOLATILE;
EOF
      ActiveRecord::Base.connection.execute(sql)
      
      puts "Creating trigger update_timestamp_trigger"
      sql = <<EOF
      CREATE or REPLACE FUNCTION update_timestamp_trigger()
      RETURNS "pg_catalog"."trigger" AS 
      $BODY$
      BEGIN
           NEW.update_timestamp = CURRENT_TIMESTAMP;
           RETURN NEW;
      END;
      $BODY$
      LANGUAGE 'plpgsql' VOLATILE;
EOF
      ActiveRecord::Base.connection.execute(sql)
    end
  
    def self.migrate_up(table, caller_binding)
      eval("add_column :#{table}, :insert_timestamp, :datetime", caller_binding)
      eval("add_column :#{table}, :update_timestamp, :datetime", caller_binding)
      
      ActiveRecord::Base.connection.execute("UPDATE #{table} SET insert_timestamp = NOW(), update_timestamp = NOW()")

      eval("say 'Adding timestamp_trigger'", caller_binding)
      sql = <<EOF
      CREATE TRIGGER #{table}_insert_timestamp BEFORE INSERT ON #{table}
          FOR EACH ROW EXECUTE PROCEDURE insert_timestamp_trigger();
      CREATE TRIGGER #{table}_update_timestamp BEFORE UPDATE ON #{table}
          FOR EACH ROW EXECUTE PROCEDURE update_timestamp_trigger(); 
EOF
      ActiveRecord::Base.connection.execute(sql)
    end
  
    def self.migrate_down(table, caller_binding)
      eval ("remove_column :#{table}, :insert_timestamp", caller_binding)
      eval ("remove_column :#{table}, :update_timestamp", caller_binding)
      ActiveRecord::Base.connection.execute("DROP TRIGGER #{table}_insert_timestamp ON #{table}")
      ActiveRecord::Base.connection.execute("DROP TRIGGER #{table}_update_timestamp ON #{table}")
    end
    
    
  end
end