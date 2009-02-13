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

require 'memcache.rb'

class MemCache
  def stats(type = '')
    raise MemCacheError, "No active servers" unless active?
    server_stats = {}

    @servers.each do |server|
      sock = server.socket
      raise MemCacheError, "No connection to server" if sock.nil?

      value = nil
      begin
        sock.write "stats #{type}\r\n"
        stats = {}
        while line = sock.gets do
          break if line == "END\r\n"
          if line =~ /^STAT ([\w]+) ([\w\.\:]+)/ then
            name, value = $1, $2
            stats[name] = case name
                          when 'version'
                            value
                          when 'rusage_user', 'rusage_system' then
                            seconds, microseconds = value.split(/:/, 2)
                            microseconds ||= 0
                            Float(seconds) + (Float(microseconds) / 1_000_000)
                          else
                            if value =~ /^\d+$/ then
                              value.to_i
                            else
                              value
                            end
                          end
          end
        end
        server_stats["#{server.host}:#{server.port}"] = stats
      rescue SocketError, SystemCallError, IOError => err
        server.close
        raise MemCacheError, err.message
      end
    end

    server_stats
  end
end

class CacheController < ApplicationController

  
  def index
  end  
  
  def data
    @memcache = get_memcache
    @servers = @memcache.stats
  end
  
private
  def get_memcache
    MemCache.new('localhost')
  end
end
