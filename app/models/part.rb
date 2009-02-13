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

class Part < ActiveRecord::Base
  
  belongs_to :message
  has_one :content_part_message, 
          :class_name => 'Message',
          :foreign_key => 'content_part_id', 
          :dependent => :nullify
  
  belongs_to :content, :dependent => :destroy
  
  def content_path
    March::MAIL_ROOT + "/#{message.list.path}/#{path}"
  end
  
  def content_type_text
    return nil if not content_type
    return content_type.split(';').first
  end
  
  def charset
    if content_type =~ /charset=([^;]+).*$/
      return $1.strip.downcase
    else
      return nil
    end
  end
  
  def path
    pairs = 5
    
    s = ""
    c = id
    1.upto(pairs) { |index|
      s = "/" + s unless index == 1
      s = sprintf("%02d", c % 100) + s
      c = (c - c % 100) / 100
    }
    s
  end

  def to_s
    "Part[id=#{id}, message_id=#{message_id}, content_type=#{content_type}, state=#{state}]"
  end
  
  def load_content(data)
    raise Exception.new("unsaved part") unless self.id
    
    if content_id
      c = self.content
      puts "   Updating content holder (#{c.id})"
      c.data = data
      c.save!
    else
      puts "   Creating new content holder"
      c = Content.new
      c.message_id = self.message_id
      c.content_type = content_type
      c.data = data
      c.save!
      self.content_id = c.id
    end
    
    self.length = c.length
  end
  
  #Only need to reindex if there is content
  def reindex
    if self.content_id
      self.content.reindex
    end
    self.indexed = true
    self.save!
  end
  
  def cache_id
    "Part=#{id}"
  end
  
end
