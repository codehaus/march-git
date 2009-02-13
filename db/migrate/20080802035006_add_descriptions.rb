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

class AddDescriptions < ActiveRecord::Migration
  def self.up
    add_column :groups, :description, :varchar, :limit => 65536
    add_column :lists, :description, :varchar, :limit => 65536
  end

  def self.down
    remove_column :groups, :description
    remove_column :lists, :description
  end
end
