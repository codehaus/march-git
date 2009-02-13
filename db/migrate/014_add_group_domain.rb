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
class AddGroupDomain < ActiveRecord::Migration
  def self.up
    add_column :groups, :domain, :string, :null => true
    
    Group.find(:all).each { |group|
      begin
        group.domain = "archive.hausfoundation.org" and next if not group.parent and group.key = 'haus'
        group.domain = "archive.#{group.key}.org" and next if group.parent.key == 'haus'
        group.domain = "archive.#{group.key}.#{group.parent.key}.org" and next if group.parent.key == 'codehaus' or group.parent.key == 'rubyhaus'
      ensure
        group.save!
      end
    }
    
    change_column :groups, :domain, :string, :null => false
  end

  def self.down
    remove_column :groups, :domain
  end
end
