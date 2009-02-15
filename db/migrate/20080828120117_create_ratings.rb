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

class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.column :user_id,    :integer,  :null=>false, :deferrable => true
      t.column :message_id, :integer,  :null=>false, :deferrable => true
      t.column :value, :integer, :null => false
      t.timestamps
    end
    
    #The rating
    #add_column :users, :negative_rating #a normal user has a negative rating "power" of -1 (admins will be -100)
    #add_column :users, :positive_rating #a normal user has a maximum rating "power" of 1
    add_column :messages, :rating_total, :integer
    add_column :messages, :rating_count, :integer
    
    Message.update_all('rating_total = 0, rating_count = 0')

    change_column :messages, :rating_total, :integer, :default => 0
    change_column :messages, :rating_count, :integer, :default => 0
    
    drop_trigger('ratings', 'rating_message_update')  
    sql = <<EOF
    CREATE OR REPLACE FUNCTION trg_rating_message() RETURNS trigger AS $$
    BEGIN
    END;
    $$ LANGUAGE plpgsql;
    CREATE TRIGGER rating_message_update BEFORE INSERT OR UPDATE OR DELETE
    ON ratings FOR EACH ROW EXECUTE PROCEDURE
    trg_rating_message();
EOF
    Content.connection.execute(sql)
    
  end

  def self.down
    drop_table :ratings
  end
  
private
  def self.drop_trigger(table, trigger)
    Content.connection.execute("DROP TRIGGER IF EXISTS #{trigger} ON #{table}")
  end
end
