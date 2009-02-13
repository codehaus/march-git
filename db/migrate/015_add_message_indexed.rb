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
class AddMessageIndexed < ActiveRecord::Migration
  def self.up
    add_column :messages, :indexed, :boolean, :null => true, :default => 'false'
    
    Message.connection.update("UPDATE MESSAGES SET INDEXED = FALSE WHERE INDEXED IS NULL")
    add_index(:messages, [:indexed])
    
    change_column :messages, :indexed, :boolean, :null => false, :default => 'false'
  end

  def self.down
    remove_column :messages, :indexed
  end
end
