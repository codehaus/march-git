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

require File.dirname(__FILE__) + '/../test_helper'

class EmailTest < ActiveSupport::TestCase
  
  def test_match
    test_internal('hello a@b.com goodbye', 
                  [ [ :text, 'hello ' ], [ :email, 'a@b.com' ], [ :text, ' goodbye' ] ] )
  end
  
  def test_match_1
    test_internal( 'mailto:test@example.com', 
                   [ [ :text, 'mailto:' ], [ :email, 'test@example.com' ] ] )
  end

  def test_match_multiline
    test_internal( "hello\nemail is test@example.com", 
                   [ [ :text, 'hello\nemail is ' ], [ :email, 'test@example.com' ] ] )
  end

  
private
  def test_internal(input, expected)
    matches = []
    March::Email.match(input) { |type,value|
      matches << [ type, value ]
    }
    
    assert_equal expected, matches, input
  end
end
