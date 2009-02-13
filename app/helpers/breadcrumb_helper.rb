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

module BreadcrumbHelper
  include LinkHelper

  def breadcrumbs()
    if not defined?(@target) or @target.nil?
      return []
    end
      
    items = build_items(@target)
    
    crumbs = []
    for item in items
      
      case ( item )
        when Group
          latest_link = link_to_rss( url_for_group( item, :rss ), "Feed of latest messages for #{item.name}" )
          crumbs << link_to_group( item.key, item ) + " " + latest_link
        when List
          latest_link = link_to_rss( url_for_list( item, :rss ), "Feed of latest messages for #{item.address}" )
          chart_link = link_to_charts( url_for_list( item, :charts ), "Charts" )
          crumbs << link_to_list( item.address, item ) + " (#{pluralize(item.messages_count, 'message')}) " + latest_link + " " + chart_link
        when Message
          crumbs << link_to_message( item.subject_precis, item )
      end
    end

    return crumbs
  end
  
private
  def build_items(current)
    case (current)
      when Group
        return build_items(current.parent) << current
      when List
        return build_items(current.group) << current
      when Message
        return build_items(current.list) << current
    end
    return []
  end
 
end
