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

#GroupHierarchy provides a high performance mapping between groups in 
#an arbitrary hierarchy.  
#
#The purpose of this hierarchy lets us quickly answer questions like,
# * Which lists are inside this root
# * How many messages are listed under this group
# 
#Without this mapping, the hierarchy would need to be walked for each question - highly inefficient 
#except for trivial cases
#

#Techical details
#----------------
#Consider a hierarchy of groups where A(X) means that A is a child of X
#A, B(A), C(A), D(B), E(D)
#The following records would be generated:
#parent, child, parent_level, child_level
#A, A, 1, 1
#A, B, 1, 2
#A, C, 1, 2
#A, D, 1, 3
#A, E, 1, 4
#B, B, 2, 2
#B, D, 2, 3
#B, E, 2, 4
#C, C, 2, 2
#D, D, 3, 3
#D, E, 3, 4
#E, E, 4, 4
#

#Using memoization to build the hierarchy would improve the performance 
#however that is left as an exercise for the optimizer.
class GroupHierarchy < ActiveRecord::Base

  belongs_to :parent_group, :class_name => 'Group', :foreign_key => 'parent_group_id'
  belongs_to :child_group, :class_name => 'Group', :foreign_key => 'child_group_id'

  def initialize(params)
    super(params)
    self.build = 0
  end


  def GroupHierarchy.rebuild()
    GroupHierarchy.connection.execute("SELECT SP_POPULATE_GROUP_CLOSURE()")
  end
  
  
  def to_s
    "GroupHierarchy[parent_group=#{parent_group}, parent_level=#{parent_level}, child_group=#{child_group}, child_level=#{child_level}]"
  end
  
  def GroupHierarchy.all_children(parent_group, parent_level)
    all_children = []
    
    parent_group.children.each { |child_group| 
      all_children << [ child_group, parent_level + 1 ]
      
      all_children(child_group, parent_level + 1).each { |child_pair| 
        all_children << child_pair
      }
    }
    all_children
  end
  
  
  
end
