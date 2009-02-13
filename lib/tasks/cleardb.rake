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

def cleardb()
  config   = ActiveRecord::Base.configurations[RAILS_ENV]

  if ( RAILS_ENV == 'production' )
    puts "sorry, that's too dangerous" 
    return
  end

  puts "Setting content_part_id to null"
  Message.update_all('CONTENT_PART_ID = NULL')
  puts "Deleting message references"
  MessageReference.connection.delete("DELETE FROM MESSAGE_REFERENCES", "MESSAGE_REFERENCES: Delete all")
  puts "Deleting parts"
  Part.connection.delete("DELETE FROM PARTS", "PARTS: Delete all")
  puts "Deleting messages"
  Message.connection.delete("DELETE FROM MESSAGES", "MESSAGES: Delete all")
  puts "Resetting message count"
  Group.update_all("CHILDREN_COUNT = 0")
  puts "Done."
end

desc 'Clears the database of all messages'
task :cleardb => [:environment] do |t|
  cleardb
end
