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
# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '2.1.0'
RAILS_GEM_VERSION = '2.3.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'march'

#Configure ad units in your site/environment file (e.g. site/production.rb)
March::GOOGLE_ADS = {}

class Rails::Configuration
  attr_accessor :action_web_service
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ]
  config.action_web_service = Rails::OrderedOptions.new

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/apis )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session_store = :mem_cache_store
  
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.gem 'pg'
  config.gem 'htmlentities', :version => '>= 4.0.0'
  config.gem 'rcov'
  config.gem 'ruby-openid', :lib => 'openid'
  config.gem 'ruby-recaptcha'
  config.gem 'chronic'
  config.gem 'packet', :version => '>= 0.1.7'

  if RAILS_ENV != 'prod'
    config.gem 'ci_reporter', :lib => 'ci/reporter/test_unit'
  end

  # See Rails::Configuration for more options
end

################################################################################
require 'migration_patches'
require 'webrick_patches'

################################################################################
March::VERSION      = 0.2
if File.exists?('revision.txt')
  March::REVISION = `cat revision.txt`.chomp
else
  March::REVISION = 'HEAD'
end

################################################################################
# Temporary queue storage
March::MAIL_QUEUE = RAILS_ROOT + '/tmp/mail-queue'


################################################################################
# Memcached Configuration
memcache_options = {
   :compression => false,
   :debug => false,
   :namespace => "march-#{RAILS_ENV}",
   :readonly => false,
   :urlencode => false
}
memcache_servers = "localhost:11211"

################################################################################
# YUI Configuration
March::YUI = '2.6.0'

################################################################################
# Trace Logging: only shown in development
if [ 'production', 'test' ].include?(RAILS_ENV)
  RAILS_DEFAULT_LOGGER.class.class_eval do
    def trace(msg = nil)
    end
  end
else  
  RAILS_DEFAULT_LOGGER.class.class_eval do
    def trace(msg = nil)
      if msg
        puts "TRACE: #{msg}"
      else
        puts "TRACE: #{yield}"
      end
    end
  end
end


