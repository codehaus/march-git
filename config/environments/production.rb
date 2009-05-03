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
# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false


#STDOUT.reopen("log/stdout.log", 'a+')
#STDOUT.sync=true

memcache_options = {
    :c_threshold => 10000,
    :compression => true,
    :debug => false,
    :namespace => "march-#{RAILS_ENV}",
    :readonly => false,
    :urlencode => false
}
memcache_servers = "localhost:11211"

#ActionController::Base.cache_store = :file_store, "./tmp/cache"
ActionController::Base.cache_store = :mem_cache_store, "localhost:11211"


production_rb = RAILS_ROOT + '/site/config/environments/production.rb'
if not File.exist?(production_rb)
  raise Exception.new("Unable to find site specific production.rb: #{production_rb}")
end

#XXX I couldn't get require or include to work properly, so I'll just eval it in-place
eval(IO.read(production_rb)) 
