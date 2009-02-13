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

