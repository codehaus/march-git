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
#Ideally the stop word is added to the postgres dictionary.
#However reindexing the entire contents table is slooooow

class StopWord < ActiveRecord::Base
  def self.create(word)
    return if not word
    word = word.to_s.strip.downcase
    return if word.blank?
    
    w = StopWord.find_or_create_by_word(word)
  end
    
end
