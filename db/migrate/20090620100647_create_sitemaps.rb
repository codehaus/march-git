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
class CreateSitemaps < ActiveRecord::Migration
  
  def self.up
    create_table :sitemaps do |t|
      t.string :name
      t.integer :first_message_id, :references => :messages
      t.integer :last_message_id, :references => :messages
      t.integer :message_count, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :sitemaps
  end
end
