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

class MessagesController < ApplicationController
  include RedactHelper
  
  before_filter :filter_list
  before_filter :filter_message
  #before_filter :cache_by_etag
  
  
  def index
    if not @message
      render :template=>'missing'
    else
      minTime = Time.rfc2822(
        request.env["HTTP_IF_MODIFIED_SINCE"]
      ) rescue nil

      response.headers['Last-Modified'] = @message.created_at.to_s
      if minTime and @message.created_at <= minTime
        return head( :not_modified )
        #return render( :nothing => true, :status => 304 )
      end
    end
  end
  
private

  def cache_by_etag(cache_key)
    cache_key_md5 = Digest::MD5.hexdigest(cache_key)
    if request.has_key?('If-None-Match') and (request['If-None-Match'].downcase == cache_key_md5.downcase)
      return head( :not_modified )
    end
    
    response['ETag'] = cache_key_md5
  end

  def filter_message
    message_id822 = params[:message]
    @message = Message.find(:first, 
                           :conditions => [ 'list_id = ? AND message_id822 = ?', @list.id, message_id822 ] )
    @target = @message
  end
end
