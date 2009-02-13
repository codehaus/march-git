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

class Targetable
  
  TARGETABLES = [ 'Group', 'List' ] 
  
  def self.find_target_by_key(target_type, target_key)
    return nil unless target_type
    return nil unless TARGETABLES.include?(target_type)
    return Group.find_by_identifier(target_key) if target_type == 'Group'
    return List.find_by_identifier(target_key) if target_type == 'List'
    raise Exception.new('Illegal arguments') #fallback
  end
  
  def self.get_target_key(target)
    return nil unless target
    return nil unless TARGETABLES.include?(target.class.name)
    return target.identifier
    raise Exception.new('Illegal arguments') #fallback
  end
  
end