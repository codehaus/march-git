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
class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :list_id,                   :integer,                :null=>false
      t.column :message_id822,             :string, :limit=>128,    :null=>false
      t.column :in_reply_to_message_id822, :string, :limit=>128,    :null=>true
      t.column :sent_at,                   :datetime,               :null=>false
      t.column :from_address,              :string, :limit=>128,    :null=>false
      t.column :from_header,               :string, :limit=>256,    :null=>false
      t.column :from_name,                 :string, :limit=>128,    :null=>true
      t.column :subject,                   :string, :limit=>1024,   :null=>false, :default=>''
    end
  end

  def self.down
    drop_table :messages
  end
end
