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
require 'optparse'
require 'time'

class March::Commands::IndexBuilder

  def self.run()
    Part.connection.execute("UPDATE parts SET vectors = to_tsvector(content), indexed = true WHERE indexed <> true")
  end
  
  def self.tool()
    options = {}
    ARGV.options do |opts|
      opts.on( '-b', '--batchsize=<batchsize>', Integer,
               'Number of messages to update per batch' ) do |batchsize|
        options[:batchsize] = batchsize
      end

      opts.on( '-f', '--force',
               'Force the rebuild' ) do |force|
        options[:force] = force
      end
      
      opts.parse!
      options[:batchsize] ||= 100
      options[:force] ||= false
    end

    do_build(options)
  end
  
  def self.do_build(options)
    last_count_unindexed = 1000000
    while true
    	batchsize = options[:batchsize]
    	force = options[:force]
    	
    	if force
    	  Message.connection.update("UPDATE MESSAGES SET INDEXED = FALSE")
    	end
    	
    	count_unindexed = Message.count(:conditions => 'not indexed')
    	
    	#Stop it from just churning over and over.
    	break if count_unindexed >= last_count_unindexed
    	last_count_unindexed = count_unindexed
    	
    	batchsize = count_unindexed if count_unindexed < batchsize
    	
    	puts("There are #{count_unindexed} unindexed messages in the system; indexing at most #{batchsize}...")
    	break if count_unindexed == 0
    end
  
  end

end
