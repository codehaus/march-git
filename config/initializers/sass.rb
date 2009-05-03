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

# Keeping compiled Sass stylesheets separate makes life a lot simpler during deployment
Sass::Plugin.options[:css_location] = RAILS_ROOT + "/public/stylesheets/compiled"

# Our very own awesome Sass extensions
module Sass::Script
  module Functions
    def timestamped_resource_url(resource)
      resource_file = RAILS_ROOT + "/public/#{resource}"
      if File.exist?(resource_file)
        resource_with_timestamp = "#{resource}?#{File.mtime(resource_file).to_i}"
      else
        resource_with_timestamp = "#{resource}?#{Time.new.to_i}"
      end
        
      return Sass::Script::String.new("url(#{resource_with_timestamp})")
    end
    
    def timestamped_image_url(image)
      timestamped_resource_url("/images/#{image}")
    end
  end
end