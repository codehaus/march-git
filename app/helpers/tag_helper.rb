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

module TagHelper

  def tag_cloud(tags)
    h = ""
    tags = tags.sort_by { |m| m.word }.collect { |m| [ m.word, m.ndoc.to_i ] }
    
    max = max_log(tags)
    
    for tag in tags
      h << " <span style='font-size: #{ font_size(tag[1], max) }'>#{tag_link(tag)}</span>"
    end
  
    return h
  end
  
private

  def tag_link(tag)
    link_to tag[0], :action => 'search', :search => tag[0]
  end
  
  def max_log(tags)
    max = 0.0
    tags.each { |tag|
      STDOUT.write tag.inspect
      amt = tag[1]
      max = amt if amt > max
    }
    return max
  end
  
  def font_size(amt, max)
    size = Math.log( amt ) / Math.log(max)
    #size = amt / max
    return '20%'  if ( size < 0.50 )
    return '30%'  if ( size < 0.60 )  
    return '40%' if ( size < 0.70 )  
    return '50%' if ( size < 0.80 )  
    return '60%' if ( size < 0.90 )  
    return '80%' if ( size < 0.95 )  
    return '90%' if ( size < 0.98 )  
    return '100%'
  end
    
  

end
