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

require 'digest/sha1'
require 'htmlentities'

class Message < ActiveRecord::Base
  include RedactHelper
  
  belongs_to :list, :counter_cache => true
  has_many :parts, :dependent => :destroy
  has_many :message_references, :dependent => :destroy
  belongs_to :content_part, :class_name => 'Part', :foreign_key => 'content_part_id', :dependent => :destroy
  #has_one :in_reply_to, 
          #:class_name=>'Message',
          #:conditions=>'in_reply_to_message_id822=\'#{message_id822}\''

  def in_reply_to
    if ( not(@in_reply_to) || @in_reply_to == false )
      message_id822 = read_attribute( :in_reply_to_message_id822 )
      if (message_id822) and (message_id822.strip != '')
        @in_reply_to = Message.find_by_message_id822(message_id822)
      end
      @in_reply_to ||= false 
    end
    @in_reply_to
  end
  
  def first_message_in_thread
    messages = Message.find_by_sql("SELECT * FROM SP_GET_FIRST_MESSAGE_IN_THREAD(#{self.id})")
    return messages.first
  end

  def replies(message_cache = nil)
    return [] if not message_id822
    return [] if message_id822.strip.length == 0
     
    logger.trace { "Looking for replies to #{Message.normalize_message_id822(message_id822)}" }

    if message_cache.empty?
      return Message.find(:all, :conditions => [ 'in_reply_to_message_id822 = ?', self.message_id822 ] )
    else
      message_cache.index_by(:in_reply_to_message_id822)
      return message_cache.get(self.message_id822)
    end
  end
  
  def path()
    list.path + "/#{message_id822}"
  end
  
  def Message.exists_by_message_id822?(message_id822)
    Message.count( :conditions => [ "message_id822 = ?", normalize_message_id822(message_id822) ] ) > 0
  end
  
  def Message.find_by_message_id(message_id822)
    Message.find(:conditions => ['message_id = ?', normalize_message_id822(message_id822) ] )
  end
  
  def normalized_subject_precis(size = 70)
    normalized = subject.to_s
    return nil if not normalized
    
    # Don't want to update original 
    normalized = '' + normalized
    # Remove the reply indicator "Re: "
    normalized.gsub!(/^\s*Re:\s*/, '')
    # Remove the list indicator "[blah] "
    normalized.gsub!(/^\[\S+\]\s*/, '')
    return Message.precis(normalized, size)
  end
  
  def subject_precis(size = 70)
    return Message.precis(subject, size)
  end
  
  def self.precis(input, size)
    return nil if not input
    
    return input if input.length < size
    
    return "#{input[0..(size-3)]}..."
  end
  
  def containing_group
    return list.group
  end   
  
  
  def before_save
    self.message_id822 = Message.normalize_message_id822(message_id822)
    self.in_reply_to_message_id822 = Message.normalize_message_id822(in_reply_to_message_id822)
  end
  
  def Message.normalize_message_id822(input)
    return nil if not input
    #http://issues.apache.org/bugzilla/show_bug.cgi?id=34602 - bugger - breaks our code horrendously
    input.gsub!(/[\/%\~\!]/, '')
    input
  end
  
  def find_best_part
    parts.each { |part| 
      return part if part.content_type =~ /text\/html/
    }

    parts.each { |part| 
      return part if part.content_type =~ /text\/plain/
    }
    
    return nil    
  end
  
  def find_searchable_content
    parts.collect { |part| 
      if part.content_type =~ /text\/plain/ or part.content_type =~ /text\/html/
        part.content
      else
        nil
      end
    }
  end
  
  
  def Message.extract_address(header)
    return nil if not header
    
    if header.strip =~ /^.*\s+<(.*)>$/
      return $1
    end
    
    return header
  end

  def Message.extract_name(header)
    return nil if not header
    
    if header.strip =~ /^(.*)\s+<.*>$/
      name = $1
      name = name[1..-2] if name[0..0] == '"' and name[-1..-1] == '"'
      return name
    end
  end
  
  #Setting from_header will overwrite the from_address and from_name
  def process_from_header(value)
    
    self.from_header = value 
    self.from_address = Message.extract_address( value )
    
    name = Message.extract_name( value )
    if name
      name = March::Rfc2047.decode_to( 'utf-8', name )
      self.from_name    = HTMLEntities.encode_entities( name, :basic, :named )
    end
  end
  
  
  def preferred_content_part
    if content_part_id == nil
      reset_content_part
    end
    
    content_part
  end
  
  #Finds the preferred content part
  #text/html
  #text/plain
  #first
  def calculate_content_part
    pts = parts
    
    #Look for unnamed text/html
    for pt in pts
      return pt if pt.content_type == 'text/html' and pt.name == nil
    end

    #Look for unnamed text/plain
    for pt in pts
      return pt if pt.content_type == 'text/plain' and pt.name == nil
    end
    
    return pts.first
  end
  
  def reset_content_part
    self.content_part = calculate_content_part
    self.save!
  end
  
  #Runs the risk of skipping messages when multiple messages sent_at same time
  def message_prev
    Message.find(:first, :conditions => [ 'id <> ? AND list_id = ? AND sent_at > ?', id, list_id, sent_at ], :order => 'sent_at', :limit => 1)    
  end
  
  #Runs the risk of skipping messages when multiple messages sent_at same time
  def message_next
    Message.find(:first, :conditions => [ 'id <> ? AND list_id = ? AND sent_at < ?', id, list_id, sent_at ], :order => 'sent_at DESC', :limit => 1)    
  end

  def message_prev_thread
    Message.find(:first, :conditions => [ 'id <> ? AND list_id = ? AND sent_at > ?', id, list_id, sent_at ], :order => 'sent_at', :limit => 1)    
  end

  def message_next_thread
    Message.find(:first, :conditions => [ 'id <> ? AND list_id = ? AND sent_at < ?', id, list_id, sent_at ], :order => 'sent_at DESC', :limit => 1)    
  end
  
  def from_address_safe
    redact_email( self.from_address )
  end
  
  def author_safe
    if from_name
      return "<span class='name'>#{from_name}</span> <span class='address'>(#{from_address_safe})</span>"
    else
      return "<span class='address address-only'>#{from_address_safe}</span>"
    end
  end
  
  def html_id
    return "message-#{id}"
  end
  
  def to_s
    "Message[id=#{id}, message_id822=#{message_id822}, from_name=#{from_name}, list=#{list.address}]"
  end
  
  def cache_id
    "Message=#{id}"
  end
  
  def identifier
    message_id822
  end
  
  # If a message doesn't contain a valid Message-Id; we generate one
  # We do not salt this Message-Id as there doesn't seem to be any real point.  An attacker 
  # could inject messages with potential future ids; but they'd also have to guess the subject and exact time
  # the sender was sending them. And the end result would be their message would be block the load of the user's
  # message. The sender would have to be sending message with no Message-Id / invalid Message-Id
  def self.synthetic_message_id822(host, date, subject)
    subject_hash = Digest::SHA1.hexdigest(subject)
    return "#{subject_hash}.#{date.utc.strftime('%Y%m%d%H%M%S')}@#{host}".downcase
  end
  
  def name
    return message_id822
  end
  
  def dump_tree(indent = '')
    logger.trace { indent + self.to_s }
    for r in replies
      r.dump_tree(indent + '  ')
    end
    nil
  end
  
  #It's faster to sum the caches than count records... bloody PostgreSQL
  def self.count_all
    List.sum(:messages_count)
  end
end
