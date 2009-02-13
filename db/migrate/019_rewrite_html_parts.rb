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
class RewriteHtmlParts < ActiveRecord::Migration
  def self.up
    count = Part.count(:conditions => "content_type LIKE 'text/html%'")
    index = 0
    Part.find(:all, :conditions => 'content_type LIKE \'text/html%\'').each { |part|
      index = index + 1
      logger.info { "#{index}/#{count}" }
      begin
      part.content = part.content
      part.save!
      rescue
        logger.error { "Problem rewriting part: #{part}" }
      end
    }
  end

  def self.down
  end
end
