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
class Sitemap < ActiveRecord::Base
  MAX_MESSAGES = 50000

  #If a sitemap is passed in, and it has capacity, it will be returned!
  def self.find_next(sitemap = nil)
    if sitemap and not sitemap.full?
      return sitemap
    end
    
    sitemap = Sitemap.find(:first, :order => 'last_message_id desc')

    if sitemap and sitemap.full?
      sitemap = nil
    end
    
    if not sitemap
      sitemap = Sitemap.new
      sitemap.message_count = 0
      sitemap.name = sprintf('%04d', ((Sitemap.maximum(:name).to_i || 0) + 1))
    end
    
    return sitemap
  end
  
  def full?
    message_count >= MAX_MESSAGES
  end
  
  def filename
    return "sitemap-#{self.name}.xml"
  end
  
  def filename_compressed
    filename + '.gz'
  end
end
