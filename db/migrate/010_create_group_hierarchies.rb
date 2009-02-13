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
class CreateGroupHierarchies < ActiveRecord::Migration
  def self.up
    create_table :group_hierarchies do |t|
      t.column :parent_group_id, :integer, :null => false, :references => :groups
      t.column :parent_level, :integer, :null => false
      t.column :child_group_id, :integer, :null => false, :references => :groups
      t.column :child_level, :integer, :null => false
      t.column :build, :integer, :null => false #Used only for building the table
    end
    
    #GroupHierarchy.rebuild()
  end

  def self.down
    drop_table :group_hierarchies
  end
end
