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

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

################################################################################
March::MAIL_ROOT  = RAILS_ROOT + "/tmp/test/mail" #XXX Deprecated?
March::MAIL_QUEUE = RAILS_ROOT + "/tmp/test/mail-queue" #Should be moved under the application

################################################################################
# Memcached Configuration
require 'memcache'
memcache_options = {
    :c_threshold => 10000,
    :compression => true,
    :debug => false,
    :namespace => "march-#{RAILS_ENV}",
    :readonly => false,
    :urlencode => false
}
CACHE = MemCache.new memcache_options
CACHE.servers = 'localhost:11211'

################################################################################
# Session Storage Configuration
session_options = {
    :database_manager => ActionController::Session::MemCacheStore,
    :cache => CACHE,
    :session_domain => 'march_#{RAILS_ENV}_session'
}
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update session_options

################################################################################
# Enable profiling
March::PROFILE = false
March::DEBUG_LOG=true

################################################################################
# Security Token
# This option controls access to the March API
March::TOKEN = 'X'

################################################################################
# Google Analytics Profile
March::GOOGLE_ANALYTICS = 'UA-5294457-1'

