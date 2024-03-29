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
class March::PopTool
  
  def self.pop(max)
    poptool = March::PopTool.new
    poptool.run(max)
  end
  
  def run(max)
    messages = []
    
    importer = March::MessageImporter.new
    
    @popper.pop_messages(:max => max) { |content|  
      messages << importer.import_mail_from_content(content)
    }
  end
  
  def initialize
    @popper = March::Popper.new( 
                                  March::MAIL_QUEUE, 
                                  :pop_user => March::POP_USERNAME, 
                                  :pop_pass => March::POP_PASSWORD, 
                                  :pop_host => March::POP_HOST, 
                                  :pop_port => March::POP_PORT 
                               )
  end
protected
  def self.logger
    RAILS_DEFAULT_LOGGER
  end
  
end