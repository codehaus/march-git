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
#require 'logger'

class March::Commands::Indexer
  LOGGER = Logger.new(STDOUT)
  
  
  def self.init_logger
    LOGGER.datetime_format = "%Y-%m-%d %H:%M:%S"
    LOGGER.info 'Starting'
  end
  
  def self.run()
  end
  
  def self.tool()
    options = {
      :batchsize => 100,
      :reindex => false
    }
    
    ARGV.options do |opts|
      opts.on( '-b', '--batchsize=<batchsize>', Integer,
               'Number of messages to update per batch' ) do |batchsize|
        options[:batchsize] = batchsize
      end

      opts.on( '-r', '--reindex',
               'Reindex all messages (slow!)' ) do |arg|
        options[:reset] = true
      end
      
      opts.on( '-h', '--help',
               'Help' ) do |arg|
        exit 0
      end
      
      opts.parse!
    end

    do_build(options)
  end
  
  def self.do_build(options)
    init_logger
    logger.info "Running indexer"
    if options[:reset]
      logger.info "Reindexing all messages"
      Content.update_all("indexed = false")
    end

    total_unindexed = Content.count(:conditions => ['NOT indexed'])
    
  	batchsize = options[:batchsize]
    while total_unindexed > 0
      Content.transaction {
        logger.info "#{total_unindexed} messages left to index"
    	
      	contents = Content.find(:all, :conditions => 'NOT indexed', :limit => batchsize)
      	logger.info "  found #{contents.length} contents to index"
    	
      	for content in contents
      	  content.save!
      	end
      	total_unindexed -= contents.length
      }
    end
  
  end
  
  def self.logger
    LOGGER
  end
end
