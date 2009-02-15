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

class CreateStopWords < ActiveRecord::Migration
  def self.up
    create_table :stop_words do |t|
      t.string :word, :null => false
      t.timestamps  
    end
    
    add_index :stop_words, :word
    
    # insignificant numbers
    1.upto(100) { |i|
      StopWord.create(i)
    }

    # years
    2000.upto(2020) { |i|
      StopWord.create(i)
    }
    
    [ 'xircles.codehaus.org', '+44', 'list', 're' ].each { |word|
      StopWord.create(word)
    }
    
    DatabaseFunction.install_all
  end

  def self.down
    drop_table :stop_words
  end
end
