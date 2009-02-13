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

#The problem with having the content mixed in with the part, is that a load of the part
#automatically caused a load of the content. In an ideal world we could lazy load; but we aren't in that world
class CreateContents < ActiveRecord::Migration
  def self.up
    rename_column :parts, :content, :content_data
    
    create_table :contents do |t|
      t.column  :data, :bytea, :null=>false
      t.column :content_type, :string, :null=>false
      t.column :clean, :boolean, :null => false
      t.column :length, :integer, :null => false
      t.column :message_id, :integer, :null => false
      t.column :list_id, :integer, :null => false
      t.timestamps
    end
    Part.reset_column_information
    
    add_column :parts, :content_id, :integer
    change_column :parts, :length, :integer, :null => true
    add_index :parts, :content_id
    add_index :contents, :list_id
    add_index :contents, :message_id
    
    DatabaseFunction.install('trg_contents_denormalization')
    sql = <<EOF
        CREATE TRIGGER trg_contents_denormalization BEFORE INSERT OR UPDATE
        ON contents FOR EACH ROW EXECUTE PROCEDURE
        trg_contents_denormalization();
EOF
        Content.connection.execute(sql)
#SELECT id, data_indexed, content_type, length, list_id, message_id from contents where id >  20;    
# update contents set list_id = null where id < 20
    
  end

  def self.down
    drop_table :contents
    rename_column :parts, :content_data, :content
    remove_column :parts, :content_id
  end
end
