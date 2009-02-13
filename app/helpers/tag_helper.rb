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

module TagHelper

  def tag_cloud(tags)
    h = ""
  
    tags = tags.sort_by { |m| m.word }.collect { |m| [ m.word, m.ndoc ] }
    for tag in tags
      h << " <span style='font-size: #{ font_size(tag, tags) }'>#{tag_link(tag, tags)}</span>"
    end
  
    return h
  end
  
private

  def font_size(element, elements)
    factor = 30 #How much the frequency boosts the size
    base = 60 #Base size
    return (factor * (element[1].to_i / elements.length) + base).to_s + '%'
  end
  
  def tag_link(tag, tags)
    link_to tag[0], :action => 'search', :search => tag[0]
  end
  

end
