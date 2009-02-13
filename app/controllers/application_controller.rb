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

#require 'recaptcha'
require 'stringio'


class CustomNotFoundError
end

class ApplicationController < ActionController::Base
  #include ReCaptcha::ViewHelper
  include March::Authentication
  include BreadcrumbHelper
  include RedactHelper
  
  before_filter :adjust_format_for_iphone
  before_filter :init_account
  before_filter :init_flash
  
  def filter_setup_march_context
    @pather = March::Pather.new( params[:root], params[:path], false )
  end
  
  def latest_id
    if not defined?(@latest_id) or @latest_id.nil?
      @latest_id = Message.maximum(:id)
    end
    return @latest_id
  end
  
  def target(level)
    if @target.class == Message
      return @target.list
    else
      return @target
    end
  end
  
  def target=(new_target)
    @target = new_target
  end
  
  def rescue_404
    rescue_action_in_public CustomNotFoundError.new
  end
  
  ##def view_paths
  #  return [ 'app/views', 'site/app/views' ] 
  #end
    
  def rescue_action_in_public(exception)
    case exception
      when CustomNotFoundError, ::ActionController::UnknownAction then
        #render_with_layout "shared/error404", 404, "standard"
        render :template => "errors/404", :status => "404"
      else
        #@reference = Xircles::Logger.log( exception, binding )
        render :template => 'errors/generic'
    end
  end
  
protected
  
  def init_flash
    [ :messages, :notices, :warnings, :errors ].each { |type| 
      if flash.has_key?(type)
        #This is done so that the flash doesn't forget about the items in it on the next request
        flash[type] = flash[type]
      else
        flash[type] = []
      end
    }
  end
  
  def search
    flash[:warnings] << 'Search not properly implemented for that page'
  end

protected
  
  def filter_list
    list_key = params[:list]
    
    if not list_key or list_key.strip.blank?
      redirect_to :action => :index
      return false
    end
    
    if (@list = List.find_by_identifier(list_key.downcase))
      @target = @list
      return true
    end

    # Handles dev@drools.codehaus.org => org.codehaus.drools.dev
    if list_key =~ /\@/
      new_list_key = list_key.split(/[\@\.]/).reverse.join('.')
      if (@list = List.find_by_identifier(new_list_key.downcase))
        #flash[:notices] << "In future, please use the list identifier '#{@list.identifier}'"
        @target = @list
        return true
      end
    end

    # Handles dev.drools.codehaus.org => org.codehaus.drools.dev
    new_list_key = list_key.split(/[\@\.]/).reverse.join('.')
    if (@list = List.find_by_identifier(new_list_key.downcase))
      #flash[:notices] << "In future, please use the list identifier '#{@list.identifier}'"
      @target = @list
      return true
    end
    
    redirect_to :action => :index
  end
  
  # Looks up the group for a given request (from :group param)
  # If no legal group can be found, redirects to the root group 
  def filter_group
    group_key = params[:group]
    @group = Group.find_by_identifier(group_key)
    if not @group
      redirect_to( :action => 'index', :group => Group.root.identifier )
      return false
    end
  
    @target = @group
  end
  
protected
  def login_required
    if current_user?
      return true
    else
      flash[:errors] << "you're not logged in!"
      redirect_to :controller => 'home'
      return false
    end
  end


private
  
  def init_account
    if session[:account_id]
      @account = Account.find(session[:account_id])
    else
      @account = nil
    end
  end
  

  private
    # Set iPhone format if request to iphone.trawlr.com
    def adjust_format_for_iphone    
      request.format = :iphone if iphone_request?
    end

    # Return true for requests to iphone.trawlr.com
    def iphone_request?
      return (request.subdomains.first == "iphone" || params[:format] == "iphone")
    end
end
