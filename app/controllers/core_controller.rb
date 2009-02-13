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

class CoreController < ApplicationController
  before_filter :filter_setup_march_context
  before_filter :init_target
  
  attr_reader :pather

  def index
    @status = 200
    if not pather.target 
      @warning = "invalid-match"
      @status = 404
      pather.target = pather.best_target
    end
    
    case ( pather.target )
      when Group
        return handle_group
      when List
        return handle_list
      when Message
        return handle_message
      when Part
        return handle_part
      when nil
        pather.target = pather.root_group
        return handle_group
    end
  end

protected

  def handle_missing
    render :template=>'core/missing', :status => 404
  end
  
  def handle_group
    flash[:notices] << 'You are accessing the archive via the old URL layout; redirected to roughly where you need to go'
    
    redirect_to :controller => 'groups', 
                :action     => 'index', 
                :message    => pather.target.identifier, 
                :status     => :moved_permanently 
  end

  def handle_list
    flash[:notices] << 'You are accessing the archive via the old URL layout; redirected to roughly where you need to go'

    redirect_to :controller => 'lists', 
                :action     => 'index', 
                :message    => pather.target.identifier, 
                :status     => :moved_permanently 
    
  end

  def handle_message
    flash[:notices] << 'You are accessing the archive via the old URL layout; redirected to roughly where you need to go'

    redirect_to :controller => 'messages', 
                :action     => 'index', 
                :list       => pather.target.list.address,
                :message    => pather.target.message_id822, 
                :status     => :moved_permanently 
  end
  
  def handle_part
    @part = pather.target
    filename = @part.name || 'attachment'
    filename.gsub!(/^["']/, '')
    filename.gsub!(/["']$/, '')

    if pather.action == :download
      disposition = 'attachment'
    else
      disposition = 'inline'
    end

    if not @part
      render :nothing => true, :status => 404
    end
    
    @content = @part.content
    if not @content
      render :nothing => true, :status => 503
    end

    if not @content.clean
      send_data 'content not available', 
                :type => 'text/plain', 
                :disposition => disposition, 
                :filename => filename
    else
      send_data @content.data, 
                :type => @content.content_type, 
                :disposition => disposition,
                :filename => filename
    end
  end
  
  def info_for_group(group)
    @messages_count = group.messages_count
    render :template => 'core/group/info'
  end
  
  def info_for_list(list)
    @messages_count = list.messages_count
    render :template => 'core/list/info'  
  end

private  
  # For legacy controllers
  def init_target
    if defined?(@group)
      @target = @group
      return
    end
    
    #fallback
    @target = Group.root
  end


end
