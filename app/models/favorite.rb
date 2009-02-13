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

class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  
  def self.find_for_target(user, target)
    return nil unless user
    return nil unless target
    return Favorite.find_by_user_id_and_target_type_and_target_id(user.id, target.class.name, target.id)
  end
  
  def self.add_for_target(user, target)
    favorite = Favorite.find_for_target(user, target)
    if not favorite
      favorite = user.favorites.build
      favorite.target = target
      favorite.save!
    end
    
    return favorite
  end
  
  def self.remove_for_target(user, target)
    favorite = Favorite.find_for_target(user, target)
    favorite.destroy if favorite
  end
  
  
  #XXX see Tagging for similar code; potentially move to mixin
  def html_id
    "favorite-#{target.class.name}-#{::Targetable.get_target_key(target)}"
  end
  
  def self.html_id_for_target(target)
    "favorite-#{target.class.name}-#{::Targetable.get_target_key(target)}"
  end
  
  def self.count_by_target_type_and_target_id( target_type, target_id ) 
    return Favorite.count( :all, :conditions => [ "target_type = ? AND target_id = ?", target_type, target_id ] )
  end

  def self.count_by_target_type_and_target_id_excluding_user_id( target_type, target_id, user_id ) 
    return Favorite.count( :all, :conditions => [ "target_type = ? AND target_id = ? AND user_id <> ?", target_type, target_id, user_id ] )
  end
  
end
