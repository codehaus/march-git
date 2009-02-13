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

class FixMimeEncodedFrom < ActiveRecord::Migration
  def self.up
    Message.find( :all, :conditions => 'from_header LIKE \'=%\'' ).each { |message| 
      begin
        before = message.from_header
        message.process_from_header( message.from_header)
        after = message.from_header
        logger.info { "#{message.id}       #{before} => #{after}" }
        message.save!
      rescue Exception => e
        puts e
        #Don't care
      end
    }
  end

  def self.down
  end
end
