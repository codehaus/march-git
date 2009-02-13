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

class User < ActiveRecord::Base
  has_many :favorites
  
  def self.cache_id(user)
    if user
      return 'User=' + user.id.to_s
    else
      return 'User=anonymous'
    end
  end
  
  def nickname_not_nil
    nickname ? nickname : fullname_not_nil
  end
  
  def fullname_not_nil
    fullname ? fullname : identifier
  end
end
