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

class RatingsController < ApplicationController
  before_filter :login_required
  before_filter :filter_message
  
  
  def cancel
    rating = find_rating(false)
    Rating.destroy(rating.id) if rating
    @message.reload
    render :partial => '/ratings/rating', :locals => { :message => @message }
  end
  
  def spam
    set_rating(- Rating::MAX)
    render :partial => '/ratings/rating', :locals => { :message => @message }
  end
  
  def set
    value = params[:value].to_i
    value = 0 if value < 0
    value = Rating::MAX if value > Rating::MAX
    
    set_rating(value)
    render :partial => '/ratings/rating', :locals => { :message => @message }
  end
  
private

  #Find the current rating entry, creating if "create" is set to true
  def find_rating(create = false)
    rating = Rating.find_by_message_id_and_user_id(@message.id, current_user_id)
    if not rating and create
      rating = Rating.new(:message_id => @message.id, :user_id => current_user_id)
    end
    return rating
  end
    
  # Sets a value on the current rating entry, creating one as required
  def set_rating(value)
    rating = find_rating(true)
    rating.value = value
    rating.save!
    @message.reload
  end

  def filter_message
    message_id = params[:message_id]
    @message = Message.find(message_id)
  end
end
