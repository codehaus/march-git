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
require 'pp'
require 'time'

class March::EmailHeader < DelegateClass(Hash) 

  attr_reader :subject, 
              :date,
              :from,
              :content_type

  def initialize(delegate)
    super( delegate )
    @subject      = first( 'subject' )
    @message_id   = first( 'message-id' )
    @date         = first_as_date( 'date' )
    @from         = first( 'from' )
    @content_type = first( 'content-type' )
    @in_reply_to  = first( 'in-reply-to' )
  end

  def message_id
    if ( ! @message_id )
      sent = date
      if ( sent ) 
        return "#{self[:hash]}-#{sent.to_i}@bogus.message.id.march.rubyhaus.org" unless @message_id
      else
        return "#{self[:hash]}@bogus.message.id.march.rubyhaus.org" unless @message_id
      end
    end
    clean_message_id( @message_id )
  end

  def in_reply_to
    return nil unless @in_reply_to
    clean_message_id( @in_reply_to )
  end

  def from_address
    return nil unless @from
    
    if ( @from =~ /<([^>]+)>/ )
      return $1
    end   
    
    @from
  end

  def from_name
    if ( @from =~ /<([^>]+)>/ )
      return @from.gsub( /<[^>]+>/, '' ).gsub( /"/, '' ).strip
    end   
    @from
  end

  def references
    return [] unless self['references']
    self['references'].collect{|chunk|chunk.split.collect{|id|
      clean_message_id( id )
    }}.flatten
  end

  private
  
  def first(name)
    values = self[name]
    return nil unless values
    values[0].strip
  end

  def first_as_date(name)
    date = first( name )
    return nil unless date
    Time.parse( date )
  end

  def clean_message_id(id)
    id.gsub( /</, '' ).gsub( />/, '' ).strip
  end


end
