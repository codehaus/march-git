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

require 'pp'
require 'optparse'
 
class March::Commands::ListLists < March::Commands::BaseCommand
  def command_options(opts)
      opts.on( '-g', '--group=<path/of/group>', String,
               'Specify group path' ) do |group|
        options[:group] = group
      end                                                   
  end

  def validate_options()
  end

  def run()

    groups = []

    if ( options[:group] ) 
      group = march.find_group( token, options[:group] )
      if ( ! group ) 
        puts "unable to find containing group"
        exit 1
      end
      groups << group
    else
      groups = march.root_groups( token )
    end

    if ( options[:group] )
      prefix = "#{options[:group]}/"
    else
      prefix = ''
    end

    for group in groups
      process_group( '', march, token, group, "#{prefix}#{group['key']}" )
    end

  end

  def process_group(indent, march, token, group, path)
    puts "#{indent}#{group['key']}/"
    lists = march.list_lists( token, path )
    for list in lists
      puts "#{indent}    - #{list['address']}"
    end
    groups = march.list_subgroups( token, path )
    for group in groups
      process_group( "#{indent}    ", march, token, group, "#{path}/#{group['key']}" )
    end
  end
end
