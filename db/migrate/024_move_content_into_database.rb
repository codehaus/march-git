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

class MoveContentIntoDatabase < ActiveRecord::Migration
  def self.up
    add_column :parts, :content, :bytea, :null => true
    add_column :parts, :state, :char, :null => true
    Part.reset_column_information
    Part.update_all("state = 'N'")
    Part.connection.execute('CREATE INDEX PART_STATE ON PARTS(STATE)')
    
    puts "Now you need to run ./script/internalize-content"
  end

  def self.down
    remove_column :parts, :content
    remove_column :parts, :indexed
  end
end
