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

require 'iconv'

module TMail
  class Mail
    
    ALLOW_MULTIPLE["delivered-to"] = true
    
    def references
      references = []
      
      body = get_header_value('References', "")
      
      pieces = body.split("<")
      pieces.collect! { |piece|
        piece = piece.strip.gsub('>', '')
      }
      for piece in pieces
        next if piece.strip == ''
        references << piece
      end
      references
    end
    
    def get_header_value(header_name, default_value = nil)
      the_header = header[header_name.downcase]
      if the_header
        return the_header.body
      else
        return default_value
      end
    end
    
  end
end


# We should be cleaning HTML parts during import
# http://plone.org/documentation/how-to/filteringhtml
class March::MessageImporter
  #include March::HeaderParser
  attr_accessor :reload
  
  #We prefer to display these types in this order 
  PREFERRED_CONTENT_TYPES = [ 'text/html', 'text/plain' ]
  MAX_CONTENT = 1000000
  DEBUG = true
  
  def initialize
    Mailer::Importer.logger = nil
  end
  
  def import_mail_from_content(content)
    Message.transaction {
      content = content.join("\n") if content.instance_of?(Array)
      return nil if content.length > MAX_CONTENT
      begin
        mail = Mailer::Importer.receive(content)
        delivered_to_headers = mail.header['delivered-to'] 
      
        if not delivered_to_headers 
          logger.warn " No 'Delivered-To' header"
          return
        end
      
        if delivered_to_headers === Array
          puts "Delivered-To: #{delivered_to_headers.first}"
        else
          puts "Delivered-To: #{delivered_to_headers}"
        end
      
        return import_mail( mail )
      rescue Exception => e
        puts e
        puts e.backtrace
      end
    }
  end
  
  def get_headers(mail, header_name)
    headers = []
    for header in mail.header
      headers << header[1] if header[0].downcase == header_name.downcase
    end
    return headers
  end
  
  def import_mail( mail )
    begin
      Message.transaction {
        if ( mail.multipart? )
          puts "Importing multipart"
          return import_multipart(mail)
        else
          puts "Importing simple"
          return import_simple( mail )
        end
      }
    rescue Exception => e
      raise e
      #puts e
      #puts "Continuing on"
      #return nil
    end
  end
  
  def import_multipart(mail)
    message = import_base_message( mail )
    return message unless message
    
    mail.parts.each { |part|
      import_part(message, mail, part)
    }
    
    return message
  end
  
  def set_better_part(message, part)
    #Dirty parts can't be the best!
    if not part.clean 
      return
    end
    
    if message.content_part
      existing_index = PREFERRED_CONTENT_TYPES.index(message.content_part.content_type)
    else
      existing_index = PREFERRED_CONTENT_TYPES.length + 1
    end
    
    new_index = PREFERRED_CONTENT_TYPES.index(part.content_type)
    new_index = PREFERRED_CONTENT_TYPES.length if new_index == -1 || new_index == nil
    
    if new_index < existing_index
      message.content_part = part
      message.save!
    end
    
  end
  
  def import_part(message, mail, mail_part)
    if mail_part.parts.length > 0
      for sub_part in mail_part.parts
        import_part(message, mail, sub_part)
      end
    else
      logger.info { "  Importing part: #{mail_part.content_type} #{mail_part.body.length}" }

      part = Part.new
      part.content_type = mail_part.content_type
      part.name ||= get_sub_header(mail_part, 'Content-Type', 'name')
      part.name ||= get_sub_header(mail_part, 'Content-Disposition', 'filename')
      part.length = 0


      #debugger if not interesting_content_type(part.content_type)
      message.parts << part

      #Must occur after message is set on part (less so now that data is in database)
      message.save!
      part.save!

      #The part can only be loaded after it is saved
      part.load_content(mail_part.body)
      part.save!
      
      set_better_part(message, part)
      logger.info { "   Done" }
    end
  end
  
  def import_simple(mail)
    message = import_base_message( mail )
    return message unless message
    
    import_body( message, mail )
    
    return message
  end
  
  def get_content_type(mail)
    if mail.header.has_key?('content-type')
      return mail.header['content-type'].body
    else
      return 'text/plain'
    end
  end
  
  def import_body( message, mail )
    part = message.parts.build
    part.content_type = get_content_type(mail)
    part.save!

    part.load_content(mail.body)
    part.save!
    
    message.content_part = part
    message.save!
  end
  
  def list_directory(list)
    groups = []
    group = list.group
    while ( group )
      groups << group
      group = group.parent
    end
    
    dir = @root
    
    if ( ! File.directory?( dir ) )
      Dir.mkdir( dir )
    end
    
    for group in groups.reverse
      dir = "#{dir}/#{group.key}"
      if ( ! File.directory?( dir ) )
        Dir.mkdir( dir )
      end
    end
    
    dir = "#{dir}/#{list.key}"
    if ( ! File.directory?( dir ) )
      Dir.mkdir( dir )
    end
    dir
  end
  
  #def delivered_to(headers)
  #  headers.each { |k,v|
  #    puts "#{k} = #{v}"
  #  }
  #  return headers['delivered-to']
  #end
  
  def determine_list(headers)
    address = nil
    
    for addr in headers['delivered-to']
      if ( addr.body =~ /^mailing list (.*)$/ )
        address = $1
        break
      end
    end
    if ( ! address )
      logger.warn { " determine_list: unable to determine list" }
      return
    else
      logger.debug { "determine_list: address #{address}" }
    end
    list = List.find_by_address( address )
    logger.warn { " determine_list: no list with address #{address}" } if not list
    return list
  end
  
  # Imports the basic message attributes from a single message
  def import_base_message(mail)
    
    list = determine_list( mail.header )
    
    if ( ! list )
      return
    end

    message_id822 = mail.get_header_value( 'Message-ID' )

    #Message-ID is semi-mandatory as per RFC-1036. 
    #Unfortunately some messages have invalid Message-Ids; and they do get sent to the list; so we *DO* 
    #want to archive them rather than simply ignoring them.
    if message_id822 == nil or message_id822.strip == ''
      message_id822 = Message.synthetic_message_id822('archive.codehaus.org', mail.date, mail.get_header_value('Subject'))
      logger.warn { " No valid Message-ID, synthesized: #{message_id822}" }
    else
      logger.info { " Found Message-ID: #{message_id822}" }
    end
    
    message_id822 = strip_message_id822( message_id822 )
    
    message = Message.find_by_list_id_and_message_id822(list.id, message_id822)
    if not requires_load?(message, message_id822)
      logger.info { " Skipping reimport of message with Message-ID: #{message_id822}" }
      return message
    end
      
    if not message
      logger.info { " Importing message with Message-ID: #{message_id822}" }
      message = Message.new
      message.message_id822             = message_id822
    else
      logger.info { " Reimporting message #{message_id822}" }
      #Clear foreign keys of dependent objects that are about to be deleted
      if message.content_part_id
        message.content_part_id = nil
        message.save!
      end

      for part in message.parts
        Part.destroy(part.id)
      end
      
      MessageReference.delete_all("message_id = #{message.id}")
    end
    
    #Now initialize the message
    message.list                      = list
    message.subject                   = mail.get_header_value('Subject')
    message.process_from_header( mail.get_header_value('From') )
    message.sent_at                   = mail.date
    message.indexed                   = false
    message.in_reply_to_message_id822 = strip_message_id822(mail.get_header_value( 'In-Reply-To' ) )
    
    for reference in mail.references
      msg_ref = MessageReference.new
      msg_ref.referenced_message_id822 = reference
      message.message_references << msg_ref 
    end 
    
    message.save!
    
    return message
  end
  
  def interesting_content_type(content_type)
    return true if content_type =~ /text\/plain/
    logger.info { " Boring content : #{content_type}" }
  end
  
  
  
  
private
  def requires_load?(message, message_id822)
    if not message
      return true
    end
    
    if message.parts.empty?
      return true
    end
    
    for part in message.parts
      if part.content == nil
        return true
      end
    end
    
    return false
  end
  
  
  def strip_message_id822(message_id)
    return nil if not message_id
    if message_id[0..0] == '<' and message_id[-1..-1] == '>'
      message_id = message_id[1..-2]
    end
    message_id
  end
  
  def get_sub_header(part, header_name, sub_header_name)
    the_header = part.header[header_name.downcase]
    return nil if not the_header
    
    the_header.body.split(";").each { |line|
      if line.index('=')
        name = line[0..(line.index('=')-1)].strip
        value = line[(line.index('=')+1)..-1].strip
        #puts name, value
        return value if name.downcase == sub_header_name.downcase
      end
    }
    nil
  end

protected
  def self.logger
    RAILS_DEFAULT_LOGGER
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
