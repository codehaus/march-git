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
class Counters < ActiveRecord::Migration
  def self.up
    add_column :lists, :messages_count, :integer, :null => true
    
    List.find(:all).each { |list| 
      list.messages_count = Message.count( :conditions => [ 'list_id = ?', list.id] )
      list.save!
    }
    
    change_column :lists, :messages_count, :integer, :null => false
    
    add_column :groups, :children_count, :integer, :null => true
    add_column :groups, :lists_count, :integer, :null => true
    
    Group.find(:all).each { |group|
      group.children_count = Group.count( :conditions => [ 'parent_id = ?', group.id ] )
      group.lists_count = List.count( :conditions => [ 'group_id = ?', group.id ])
      group.save!
    }
    
    change_column :groups, :children_count, :integer, :null => false
    change_column :groups, :lists_count, :integer, :null => false
  end

  def self.down
    remove_column :lists, :messages_count
    remove_column :groups, :children_count
    remove_column :groups, :lists_count
  end
end
