################################################################################
#  Copyright 2007-2009 Codehaus Foundation
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

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
load 'config/deploy'

##########################################################################################
if not ENV['CUSTOMER']
  puts("You must specify a customer using the CUSTOMER=<customer key> notation")
  exit -1
end

customer = ENV['CUSTOMER'].strip.downcase
set :customer, customer

customer_deploy_rb = File.dirname(__FILE__) + "/config/customer/#{customer}/deploy.rb"
if not File.exist?(customer_deploy_rb)
  puts("No customer specific deploy.rb found: #{customer_deploy_rb}")
  exit -1
end

load customer_deploy_rb

puts "Deploying to #{customer}"

