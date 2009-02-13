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
class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.column :group_id,           :integer,              :null=>true
      t.column :address,            :string,  :limit=>128, :null=>false
      t.column :url,                :string,  :limit=>512, :null=>true
      t.column :subscriber_address, :string,  :limit=>128, :null=>true
    end
  end

  def self.down
    drop_table :lists
  end
end
