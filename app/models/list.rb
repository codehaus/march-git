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

class List < ActiveRecord::Base
  belongs_to :group, :counter_cache => true
  has_many :messages, :order=>'sent_at DESC'

  def path
    group.path + "/#{key}"
  end
  
  def containing_group
    return group
  end   
  
  def recent(limit = 10)
    Message.find(:all, :conditions => [ 'list_id = ?', self.id ], :order => 'sent_at DESC', :limit => limit)
  end
  
  def self.find_by_path(path)
    segments = path.downcase.split( '/' )
    
    group = Group.find_by_path( segments[0..-2].join('/') )
    return nil unless group

    return group.lists.find_by_key( segments[-1] )
  end
  
  def before_create
    messages_count = 0 if not messages_count
  end  
  
  def to_s
    "List[id=#{id}, key=#{key}, group=#{group}, messages_count=#{messages_count}]"
  end
  
  
  def name
    address
  end
  
  def cache_id
    "List=#{id}"
  end
  
  def self.count_all
    Group.sum(:lists_count)
  end
  
end
