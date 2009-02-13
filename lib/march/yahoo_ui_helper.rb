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

#Usage:
#  Your page:
# => <% init_yui( :component, 'tabview' )%>
# => <% init_yui( :stylesheet, 'tabview/assets/tabview' ) %>
# => <% init_yui( :stylesheet, 'tabview/assets/border_tabs' ) %>
#  Your application.rhtml
# => <%= render_yui() %>
#
# Dependant YUI libraries will be automatically included (as best we know)
module March::YahooUiHelper
  # init_yui( [ 'tabview' ], [ 'tabview/assets/tabview', 'tabview/assets/border_tabs'])
  def init_yui( type, *items )
    list = get_list(type)

    for item in items
      list << item unless list.include?(item)
    end
  end
  
  # Renders the various pieces into the <head> element
  def render_yui
    components = get_list(:component)
    return if components.empty?
    
    result = <<EOF
<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/#{ March::YUI }/build/reset-fonts-grids/reset-fonts-grids.css"/>
<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/#{ March::YUI }/build/base/base-min.css"/>

<script type='text/javascript' src='http://yui.yahooapis.com/#{ March::YUI }/build/yahoo/yahoo-min.js'></script>
<script type='text/javascript' src='http://yui.yahooapis.com/#{ March::YUI }/build/yuiloader/yuiloader-min.js'></script>
<script type='text/javascript'>
//<![CDATA[
init_functions = new Array();
var loader = new YAHOO.util.YUILoader({
  require: #{components.to_json},
  onSuccess: function() { 
    for (i = 0; i < init_functions.length; i++) {
      init_functions[i]();
    }
  },
  skin: {
    defaultSkin: 'sam'
  }
});


loader.insert();
// ]]>
</script>  
EOF
    
    return result    
  end

private
  def get_list(type)
    @yui_lists ||= {}
    @yui_lists[type] ||= []
    return @yui_lists[type]
  end
  
end
