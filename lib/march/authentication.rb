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

module March::Authentication
  @@user = nil
  
  #Faster than current_user as it doesn't do a DB lookup
  def current_user?
    return session[:user_id] != nil
  end
  
  def current_user
    user_id = session[:user_id]
    if user_id
      return User.find(user_id)
    end
    
    return nil
  end
  
  def current_user_id
    session[:user_id]
  end
  
  def clear_current_user
    session[:user_id] = nil
  end
  
  def set_current_user(user)
    raise Exception.new("user class was #{user.class.name} rather than #{User.name}") unless user.class.name == User.name
    set_current_user_id(user.id)
  end

  def set_current_user_id(user_id)
    session[:user_id] = user_id
  end
  
  def logout_all
    clear_current_user
    clear_current_real_user
  end  
  
  def impersonating?
    return session[:real_user_id] != nil
  end
  
  def set_real_user(user)
    raise Exception.new("user class was #{user.class.name} rather than #{User.name}") unless user.class.name == User.name
    session[:real_user_id] = user.id
  end
  
  def current_real_user?
    return session[:real_user_id] != nil
  end

  def current_real_user
    real_user_id = session[:real_user_id]
    if real_user_id
      return User.find(real_user_id)
    end
    
    return nil
  end

  def current_real_user_id
    session[:real_user_id]
  end
  
  def clear_current_real_user
    session[:real_user_id] = nil
  end
  
  
end
