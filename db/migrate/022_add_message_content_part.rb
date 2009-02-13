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
class AddMessageContentPart < ActiveRecord::Migration
  def self.up
    add_column :messages, :content_part_id, :integer, :null => true, :references => :parts
    #Message.connection.execute("UPDATE MESSAGES SET CONTENT_PART_ID = (SELECT MIN(P.ID) FROM PARTS P WHERE P.MESSAGE_ID = M.ID) FROM MESSAGES M")
    
    #Without this, the foreign key will be abysmally slow to check during a DELETE of PARTS
    Message.connection.execute ("CREATE INDEX MESSAGES_CONTENT_PART_ID ON MESSAGES(CONTENT_PART_ID)")
    
    #change_column :messages, :content_part_id, :integer, :null => false
  end

  def self.down
    remove_column :messages, :content_part_id
  end
end
