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
require 'chronic'

class CreateDays < ActiveRecord::Migration
  def self.up
    create_table( :days, :id => :dt ) do |t|
      t.column :dt, :date
      t.column :is_weekday, :boolean
      t.column :is_holiday, :boolean
      t.column :y, :integer
      t.column :fy, :integer
      t.column :q, :integer
      t.column :m, :integer
      t.column :d, :integer
      t.column :dw, :integer
      t.column :monthname, :string, :limit => 9
      t.column :dayname, :string, :limit => 9
      t.column :w, :integer
    end
    
    DatabaseFunction.install('sp_build_days')
    DatabaseFunction.exec("sp_build_days ('#{Chronic.parse('10 years ago')}','#{Chronic.parse('10 years from now')}')")
  end

  def self.down
    drop_table :days
  end
  
end
