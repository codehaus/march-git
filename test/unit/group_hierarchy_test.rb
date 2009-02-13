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

require File.dirname(__FILE__) + '/../test_helper'

class GroupHierarchyTest < Test::Unit::TestCase
  all_fixtures

  def test_stuff
    Part.delete_all
    Message.delete_all
    List.delete_all
    Group.delete_all
    d = "goudahaus.net"
    group_A = create_group(:key => 'A', :name => 'A', :domain => d)
    group_C = create_group(:key => 'C', :name => 'C', :parent_id => group_A.id, :domain => d)
    group_B = create_group(:key => 'B', :name => 'B', :parent_id => group_A.id, :domain => d)
    group_D = create_group(:key => 'D', :name => 'D', :parent_id => group_B.id, :domain => d)
    group_E = create_group(:key => 'E', :name => 'E', :parent_id => group_D.id, :domain => d)
    
    items = GroupHierarchy.all_children(group_A, 1)
    for item in items
      #puts "ZEE CHILDPAIR: #{item[0]} #{item[1]}"    
    end
  end
  
  def test_rebuild
    nuke
    
    #GroupHierarchy.methods.each { |method|
    #  puts "Method: #{method}"
    #}
    
    d = "goudahaus.net"
    group_A = create_group(:key => 'A', :name => 'A', :domain => d)
    group_C = create_group(:key => 'C', :name => 'C', :parent_id => group_A.id, :domain => d)
    group_B = create_group(:key => 'B', :name => 'B', :parent_id => group_A.id, :domain => d)
    group_D = create_group(:key => 'D', :name => 'D', :parent_id => group_B.id, :domain => d)
    group_E = create_group(:key => 'E', :name => 'E', :parent_id => group_D.id, :domain => d)

    GroupHierarchy.rebuild()    
    
    items = GroupHierarchy.find(:all)

    
    #assert_equal 12, items.length
    puts "#" * 80
    for item in GroupHierarchy.find(:all)
      puts "Item: #{item}"
    end
    
    assert check_group_hierarchy(items, group_A, 1, group_A, 1)
    assert check_group_hierarchy(items, group_A, 1, group_B, 2)
    assert check_group_hierarchy(items, group_A, 1, group_C, 2)
    assert check_group_hierarchy(items, group_A, 1, group_D, 3)
    assert check_group_hierarchy(items, group_A, 1, group_E, 4)
    
    assert check_group_hierarchy(items, group_B, 2, group_B, 2)
    assert check_group_hierarchy(items, group_B, 2, group_D, 3)
    assert check_group_hierarchy(items, group_B, 2, group_E, 4)
    
    assert check_group_hierarchy(items, group_C, 2, group_C, 2)
    
    assert check_group_hierarchy(items, group_D, 3, group_D, 3)
    assert check_group_hierarchy(items, group_D, 3, group_E, 4)
    
    assert check_group_hierarchy(items, group_E, 4, group_E, 4)
    

    assert_equal 0, items.length
    
  end
  
private
  def nuke
    Part.delete_all
    Message.delete_all
    List.delete_all
    GroupHierarchy.delete_all
    Group.delete_all
  end
  
  def check_group_hierarchy(items, parent_group, parent_level, child_group, child_level)
    items.each { |item| 
      next if item.parent_group != parent_group
      next if item.parent_level != parent_level
      next if item.child_group != child_group
      next if item.child_level != child_level
      
      items.delete(item)
      return true
    }

    puts "Missing GroupHierarchy[parent_group=#{parent_group.path}, parent_level=#{parent_level}, child_group=#{child_group.path}, child_level=#{child_level}]"
    return false
  end

  def create_group(options)
    group = Group.new(options)
    group.save!
    group
  end
  

end
