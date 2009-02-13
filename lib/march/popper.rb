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

require 'net/pop'
require 'fileutils'

class March::Popper

  def initialize(queue_dir,
                 options={})
    @queue_dir = queue_dir
    @options   = options
    @options[:pop_port] ||= 110
  end

  def pop_messages(options = {})
    if ( ! File.exists?( @queue_dir) )
      FileUtils.mkdir_p( @queue_dir )
    end
    
    options[:max] ||= 1000000
    
    puts "Downloading a maximum of #{options[:max]} messages"
    puts " Server: #{@options[:pop_host]}"
    puts " Port:   #{@options[:pop_port]}"
    puts " User:   #{@options[:pop_user]}"

    #We use the vpopmail side as the queue, we receive one message, process it, and if all that works, we delete from server.
    #There is no penalty for multi-downloading as we check the message-id first.
    Net::POP3.start( @options[:pop_host],
                     @options[:pop_port],
                     @options[:pop_user],
                     @options[:pop_pass], 
                     false ) do |pop|
      index = 0
      pop.each_mail do |mail|
        queue_file = "#{@queue_dir}/#{mail.unique_id}"
        index = index + 1
        break if index > options[:max]
        
        if ( ! File.exists?( queue_file ) )
          puts "fetch[#{index}]: #{mail.unique_id}"
          File.open( queue_file, 'w' ) do |file|
            mail.pop do |chunk|
              file.write chunk
            end 
          end
        end

        if ( block_given? )
          begin
            yield( queue_file )
            mail.delete
          rescue Exception => e
            puts "#{e}" 
          end
        end
      end
    end
  end

end
