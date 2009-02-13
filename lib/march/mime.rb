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

require 'digest/sha1'

module March::Mime

  def read_email_headers(io)
    headers = read_mime_headers(io)
    if ( ! headers['message-id'] )
      headers['message-id'] = [ "synthetic.#{headers[:hash]}@xircles.net" ]
    else
      headers['message-id'][0] = headers['message-id'][0].gsub( /</, '' ).gsub( />/, '' )
    end

    if ( headers['references'] )
      refs = headers['references'].collect{|chunk|chunk.split.collect{|message_id|
        message_id.gsub( /</, '' ).gsub( />/, '' )
      }}
      refs.flatten!
      headers['references'] = refs
    end

    headers
  end

  def read_mime_headers(io)
    header_lines = []
    while ( ! io.eof? )
      line = io.readline
      if ( line.strip == '' ) 
        break
      else
        header_lines << line
      end
    end

    header_hash = Digest::SHA1.hexdigest( header_lines.join( '' ) )

    current = nil

    joined_header_lines = []
  
    for line in header_lines
      if ( current == nil )
        current = line.chomp
      else
        if ( line =~ /^\s/ )
          current = current + line.chomp.gsub( /^\s+/, ' ' )
        else
          joined_header_lines << current
          current = line.chomp
        end
      end 
    end
    joined_header_lines << current

    headers = {}
  
    for line in joined_header_lines
      if ( line =~ /([^:]+):(.*)/ )
        key   = $1.strip.downcase
        value = $2.strip
        if ( headers[key] )
          headers[key] << value
        else
          headers[key] = [ value ]
        end
       end
    end   

    headers[:hash] = header_hash
    headers
  end

end
