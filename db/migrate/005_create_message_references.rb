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
class CreateMessageReferences < ActiveRecord::Migration
  def self.up
    create_table :message_references do |t|
      t.column :message_id,               :integer,             :null=>false
      t.column :referenced_message_id822, :string, :limit=>128, :null=>false
    end
    MessageReference.connection.execute("create index message_references_message_id on message_references(message_id)")
  end

  def self.down
    drop_table :message_references
  end
end
