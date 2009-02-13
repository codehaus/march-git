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

class March::Commands::BaseCommand

  def self.run()
    cmd = self.new
    cmd.fire
  end

  def initialize(argv=ARGV)
    @argv = argv
    @options = {}
  end

  def parse_options()
    @argv.options do |opts|
      opts.on( '--username=<username>', String,
               'Username for authentication' ) do |username|
        options[:username] = username
      end
      opts.on( '--password=<password>', String,
               'Password for authentication' ) do |password|
        options[:password] = password
      end
      opts.on( '--url=<url>', String,
               'URL for API (defaults to http://localhost:3000/march/api)' ) do |url|
        options[:url] = url
      end
      command_options(opts)
      opts.parse!
      begin
        validate_options
      rescue => msg
        logger.error { msg }
        exit 1
      end
      options[:url]      ||= 'http://localhost:3000/march/api'
      options[:username] ||= 'admin'
      options[:password] ||= ''
    end
  end

  def command_options(opts)
  end

  def validate_options()
  end

  def options
    @options
  end

  def march
    @march
  end

  def token
    @token
  end

  def fire()
    parse_options
    puts "Connecting to #{options[:url]}"
    @march = ActionWebService::Client::XmlRpc.new( ::MarchApi, options[:url] )
    @token = march.login( options[:username], options[:password] )
    run()
  end

  def run()
    "you must override run()"
  end
  
protected

  def logger
    RAILS_DEFAULT_LOGGER
  end



end
