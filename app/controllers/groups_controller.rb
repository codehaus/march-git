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

class GroupsController < ApplicationController
  include SearchHelper
  before_filter :filter_group
  before_filter :allow_search
  #before_filter :parse_query, :only => 'search'
  
  def index
    @frequency = 30
    @frequency = 5 if RAILS_ENV == 'development'
  end
  
  def info
  end
  
  def charts_xml
    @sql = <<EOF
    SELECT 
      TO_CHAR( d.dt, 'YYYY/MM' ) AS YYYYMM,
      MIN(d.dt) AS dt,
      SUM(MESSAGE_COUNT) AS MESSAGE_COUNT
    FROM days D
    LEFT OUTER JOIN 
    (
      SELECT 
        CAST(m.sent_at AS DATE) AS dt,
        COUNT(*) AS MESSAGE_COUNT
      FROM messages m, lists l, group_hierarchies gh
      WHERE gh.parent_group_id = #{@group.id}
        AND l.id = m.list_id
        AND gh.child_group_id = l.group_id
      GROUP BY CAST(m.sent_at AS DATE)
    ) DATA ON D.dt = DATA.dt
    WHERE
      d.dt < NOW()
    GROUP BY 
      TO_CHAR( d.dt, 'YYYY/MM' ),
      d.y
    ORDER BY 
      TO_CHAR( d.dt, 'YYYY/MM' );
EOF
    render :template => '/charts/activity.rxml', :layout => false
  end
  
  def latest
    @messages = latest_messages
    render :template => '/common/latest'
  end
  
  def latest_data
    @messages = latest_messages
    render :template => '/common/latest_data', :layout => false
  end
  
  def rss
    @messages = latest_messages
    render :template => '/lists/rss', :layout => false, :content_type => 'text/xml'
  end
  
  def ajax_latest
    render :layout => false
  end
  
  def ajax_tags
    render :layout => false
  end
  
  
private
  def latest_messages(count = 25)
    return Message.find_by_sql(
      [ "SELECT * FROM sp_latest_messages_for_group(?, ?) ORDER BY sent_at DESC LIMIT ?", @group.id, count, count ]
    )
  end

  def allow_search
    @searchable = true
  end
  
end
