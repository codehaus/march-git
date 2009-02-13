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

class AddIdentifier < ActiveRecord::Migration
  def self.up
    add_column :lists, :identifier, :varchar, :length => 255, :null => true
    for list in List.find(:all)
      identifier = list.address.gsub(/\@/, '.')
      identifier = identifier.split('.').reverse.join('.')
      list.identifier = identifier
      list.save!
    end
    change_column :lists, :identifier, :varchar, :length => 255, :null => false
    
    add_index :lists, :identifier

    add_column :groups, :identifier, :varchar, :length => 255, :null => true
    for group in Group.find(:all)
      group.identifier = group.path.gsub(/\//, '.')
      group.save!
    end
    change_column :groups, :identifier, :varchar, :length => 255, :null => false

    add_index :groups, :identifier
    
  end

  def self.down
    remove_column :lists, :identifier
    remove_column :groups, :identifier
  end
end
