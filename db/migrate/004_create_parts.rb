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
class CreateParts < ActiveRecord::Migration
  def self.up
    create_table :parts do |t|
      t.column :message_id,   :integer,             :null=>false
      t.column :content_type, :string, :limit=>128, :null=>false
      t.column :path,         :string, :limit=>256, :null=>false
    end
  end

  def self.down
    drop_table :parts
  end
end
