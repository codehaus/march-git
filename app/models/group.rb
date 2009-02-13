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

class Group < ActiveRecord::Base
  acts_as_tree :counter_cache => :children_count #Just setting true *should* be enough, but it isn't for some reason
  has_many :lists

  def path
    return "#{parent.path}/#{key}" if parent
    return key
  end

  def subscriber_host
    March::SUBSCRIBER_HOST
  end

  def self.find_by_path(path)
    segments = path.split( '/' )
    current = Group.find_by_key_and_parent_id( segments.shift, nil )
    return nil unless current
    for segment in segments
      current = current.children.find_by_key( segment )
      return nil unless current
    end 
    return current
  end
  
  
  def to_s
    "Group[id=#{id}, key=#{key}]"
  end

  def root=(new_root)
    @root = new_root
  end
    
  def root
    if defined?(@root)
      return @root
    end
    
    if not defined?(@root_cache)
      @root_cache = Group.find(:first, :conditions => [ 'parent_id IS NULL' ] )
    end
    
    return @root_cache
  end
  
  def messages_count()
    sql = <<EOF
SELECT SUM(messages_count) 
FROM LISTS 
WHERE GROUP_ID IN (
  SELECT CHILD_GROUP_ID 
  FROM GROUP_HIERARCHIES GH 
  WHERE GH.PARENT_GROUP_ID = #{id}
) OR GROUP_ID = #{id}
EOF
    sum = Group.connection.select_value(sql)
    sum ? sum.to_i : 0
  end

  #Total of all lists below this group (not just the immediate children)
  def lists_count_total()
    sql = <<EOF
SELECT SUM(lists_count) 
FROM GROUPS
WHERE ID IN (
  SELECT CHILD_GROUP_ID 
  FROM GROUP_HIERARCHIES GH 
  WHERE GH.PARENT_GROUP_ID = #{id}
)
EOF
    sum = Group.connection.select_value(sql)
    sum ? sum.to_i : 0
  end
  
  def containing_group
    return self
  end

  def recently_active(count = 10)
    return List.find_by_sql(['SELECT * FROM sp_active_lists(?, ?)', id, count])
  end
  
  def before_create
    children_count = 0 if not children_count
    lists_count = 0 if not lists_count
  end
  
  def cache_id
    "Group=#{identifier}"
  end

end
