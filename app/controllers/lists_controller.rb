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

class ListsController < ApplicationController
  include SearchHelper
  #require 'recaptcha'
  #include ReCaptcha::ViewHelper
  
  before_filter :filter_list, :except => [ :index ]
  before_filter :filter_target
  before_filter :allow_search
  
  def index
    @target = Group.root
    @lists = List.find(:all, :conditions => ['messages_count > ?', 0], :order => 'messages_count DESC')
  end
  
  def info
    @messages = @list.messages.find(:all, :conditions => [ 'not sp_message_is_spam(id)' ], :order => 'sent_at DESC', :limit => 10)
  end
  
  def browse
    @messages = Message.paginate_by_list_id @list.id, 
            :page => params[:page], 
            :per_page => 25, 
            :include => [ :list ], 
            :order => 'sent_at DESC',
            :total_entries => @list.messages_count
  end
  
  def latest
    @title = @list.address
    @messages = @list.messages.find(:all, :conditions => [ 'not sp_message_is_spam(id)' ], :order => 'sent_at DESC', :limit => 25)
  end

  def rss
    @title = @list.address
    @messages = @list.messages.find(:all, :order => 'sent_at DESC', :limit => 25)
    render :layout => false, :content_type => 'text/xml'
  end
  
  def chart
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
      FROM messages m
      WHERE m.list_id = #{@list.id}
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
  
private
  def filter_target
    @target = @list
  end
  
  def allow_search
    @searchable = true
  end
  
    
end
