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

class AddPartClean < ActiveRecord::Migration
  def self.up
    #It has basically become impossible to reliably clean HTML; so we're giving up
    #If a Part can't be cleaned, we store it in its original dirty state and mark it as such
    add_column :parts, :clean, :boolean, :null => true
    Part.update_all('clean = true')
    change_column :parts, :clean, :boolean, :default => false, :null => true
  end

  def self.down
    remove_column :parts, :clean
  end
end
