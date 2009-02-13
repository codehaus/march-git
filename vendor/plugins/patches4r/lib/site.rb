################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

SITE_ROOT = File.join(RAILS_ROOT, 'site')
module Dependencies
  def require_or_load(file_name)
    file_name = "#{file_name}.rb" unless ! load? || file_name [-3..-1] == '.rb'
    load? ? load(file_name) : require(file_name)
    if file_name.include? 'controller'
      file_name = File.join(SITE_ROOT, 'app', 'controllers',  File.basename(file_name))
      if File.exist? file_name
        load? ? load(file_name) : require(file_name)
      end
    end
  end
end
