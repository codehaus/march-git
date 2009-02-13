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
class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :parent_id, :integer, :null=>true, :deferrable => true
      t.column :key,       :string, :limit=>64,  :null=>false
      t.column :name,      :string, :limit=>128, :null=>true
      t.column :url,       :string, :limit=>512, :null=>true
    end
  end

  def self.down
    drop_table :groups
  end
end
