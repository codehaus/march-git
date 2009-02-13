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

class March::Commands::AddList < March::Commands::BaseCommand

  def command_options(opts)
    opts.on( '-k', '--key=<key>', String,
             'Key of the list' ) do |key|
      options[:key] = key
    end
    opts.on( '-a', '--address=<address>', String,
             'Email address of the list' ) do |address|
      options[:address] = address
    end
    opts.on( '-g', '--group=<path/of/group>', String,
             'Specify group path' ) do |group|
      options[:group] = group
    end                                                   
    opts.on( '-i', '--info=<url>', String,
             'Specify Info URL' ) do |info|
      options[:info] = info
    end                                                   
  end

  def validate_options()
    raise "you must specify an address" unless options[:address]
    raise "you must specify a key" unless options[:key]
    raise "you must specify a group" unless options[:group]
    raise "you must specify a URL" unless options[:url]
  end

  def run()

    begin
      list = march.new_list( token, options[:group], options[:key], options[:address], options[:info] )
    rescue => message
      puts "error creating list: #{message}"
      return
    end

    raise "unable to create list" unless list

    puts "created list #{list['address']} #{list['subscriber_address']}"

  end
end
