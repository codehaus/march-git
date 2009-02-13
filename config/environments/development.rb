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
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

config.logger = ActiveSupport::BufferedLogger.new(STDERR)

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false


#puts "Trapping USR1"
#Signal.trap "USR1" do
#  fork do
#    ObjectSpace.each_object(Thread) do |th|
#      th.raise Exception, "Stack Dump" unless Thread.current == th
#    end
#    raise Exception, "Stack Dump"
#  end
#end 


#memcache_options = {
#    :c_threshold => 10000,
#    :compression => true,
#    :debug => false,
#    :namespace => "march-#{RAILS_ENV}",
#    :readonly => false,
#    :urlencode => false
#}

#CACHE = MemCache.new memcache_options
#CACHE.servers = 'localhost:11211'

#session_options = {
#    :database_manager => CGI::Session::MemCacheStore,
#    :cache => CACHE,
#    :session_domain => 'march_development_session'
#}

#ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update session_options

ActionController::Base.cache_store = :mem_cache_store, "localhost:11211"


site_rb = RAILS_ROOT + '/site/config/environments/development.rb'
if not File.exist?(site_rb)
  raise Exception.new("Unable to find site specific configuration: #{site_rb}")
end

#XXX I couldn't get require or include to work properly, so I'll just eval it in-place
eval(IO.read(site_rb))

March::PROFILE = false

ActiveRecord::Base.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_database.log")

ActiveRecord::Base.logger.class.class_eval do
  def trace(s = nil)
    return #No trace for now
    if s
      puts "TRACE: #{s}"
    else
      puts "TRACE: #{yield}"
    end
  end
end
