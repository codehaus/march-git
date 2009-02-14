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
require 'yaml'

class ApiControllerTest < ActionController::TestCase
  all_fixtures
  
  def test_invalid_token
    get :update_group, { :token => 'wrong' }
    assert_response 403
  end
  
  def test_update_group_new
    get :update_group, { :token => March::TOKEN, :identifier => 'haus' }
    assert_response 200
    g = YAML.load(@response.body)
    puts g.inspect
  end
end
