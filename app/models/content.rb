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

class Content < ActiveRecord::Base
  has_one :part, :dependent => :nullify
  
  def data=(new_data)
    puts "data=#{new_data.length}"
    puts content_type
    if self.content_type =~ /text\/html/ and new_data != nil
      logger.info { "Cleaning content (#{new_data.length})..." }
      
      begin
        puts "cleaning #{new_data.length} bytes"
        File.open("pre.html", 'w') { |io| io.write(new_data) }
        new_data = March::HtmlCleaner.new().clean(new_data)
        puts "cleaned #{new_data.length} bytes"
        self.clean = true
      rescue Exception => e
        self.clean = false
        puts "Failed cleaning content; marking content as dirty (#{e})"
      end
    else
      self.clean = true
    end
    puts "Set self.clean to #{self.clean}"
    write_attribute(:data, new_data)
    if new_data
      self.length = new_data.length
    else
      self.length = nil
    end
  end
end
