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

require 'optparse'

class March::Commands::AddGroup < March::Commands::BaseCommand

  def command_options(opts)
      opts.on( '-k', '--key=<key>', String,
               'Key of the new group' ) do |key|
        options[:key] = key
      end
      opts.on( '-p', '--parent=<path/of/parent>', String,
               'Specify parent group path' ) do |parent|
        options[:parent] = parent
      end                                                   
      opts.on( '-n', '--name=<name>', String,
               'Name of the new group' ) do |name|
        options[:name] = name
      end                                                   
  end

  def validate_options()
    raise 'you must specify a group key' unless options[:key]
  end

  def run()
    begin
      group = march.new_group( token, 
                               options[:parent] || '', 
                               options[:key], 
                               options[:name] || '', 
                               options[:url] || '',
                               options[:domain] || '' )
    rescue => message
      logger.info { "error creating group: #{message}" }
      return
    end
    
    if ( options[:pop_host] )
      if ( options[:parent] )
        path = "#{options[:parent]}/#{options[:key]}"
      else
        path = options[:key]
      end
    end

    if ( ! group ) 
      logger.info { "unable to add group" }
    else
      logger.info { "created: #{group['path']}" }
    end
  end
end
