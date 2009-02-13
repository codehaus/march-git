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

class FavoritesController < ApplicationController
  before_filter :login_required
  
  verify :method => :post, :only => [ :add, :remove ],
         :redirect_to => { :controller => '/errors', :message => 'get method prohibited for action' }
  
  
  def index
    @favorites = current_user.favorites
  end
  
  
  def add
    #sleep(5) #For testing scriptaculous effects
    target_type = params[:target_type]
    target_key = params[:target_key]
    
    target = Targetable.find_target_by_key(target_type, target_key)
    if target
      Favorite.add_for_target(current_user, target)    
      return render( :partial => 'favorite_icon', :locals => { :target => target } )
    end
    render :text => ''
  end
  
  def remove
    #sleep(5) #For testing scriptaculous effects
    target_type = params[:target_type]
    target_key = params[:target_key]
    puts "removing"
    target = Targetable.find_target_by_key(target_type, target_key)
    puts " target: #{target}"
    logger.warn("#{@current_user}: Trying to remove target that doesn't exist: #{target_type}/#{target_key}")
    if target
      puts "removing target"
      Favorite.remove_for_target(current_user, target)
      return render( :partial => 'favorite_icon', :locals => { :target => target } )
    end
    render :text => ''
  end
  
end
