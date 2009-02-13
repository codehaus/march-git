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
require 'yaml'
class AddCreatedAt < ActiveRecord::Migration
  def self.up
    begin
    puts 'A' * 80
    add_column :messages, :created_at, :timestamp, :null => true, :default => 'now()'
  #  puts 'B' * 80
   # Message.connection.update("UPDATE MESSAGES SET CREATED_AT = NOW()")
    puts 'C' * 80
  #  puts 'D' * 80
  rescue Exception => e
    puts e.inspect
    puts e.to_yaml
    puts e.caller.join("\n")
    raise e
  end
  end

  def self.down
    remove_column :messages, :created_at
  end
end
