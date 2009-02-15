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

class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :identifier, :null => false
      t.string :nickname, :null => true
      t.string :fullname, :null => true
      t.timestamps
    end
    
    create_table :favorites do |t|
      t.column :user_id,        :integer, :null=>false, :deferrable => true
      t.column :target_type, :string,  :null=>false, :limit=>128
      t.column :target_id,   :integer, :null=>false, :references => nil
      t.column :created_at, :timestamptz, :null => true
      t.column :updated_at, :timestamptz, :null => true
    end
  end

  def self.down
    drop_table :favorites
    drop_table :users
  end
end
