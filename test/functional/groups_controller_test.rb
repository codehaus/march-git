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

class GroupsControllerTest < ActionController::TestCase
  all_fixtures
  
  def setup
    @root_group = Group.root
  end
  
  def test_index_redirect
    get :index
    assert_redirected_to :controller => 'groups', :group => @root_group.key
  end

  def test_index
    get :index, { :group => @root_group.key }
    assert_response :success
  end
  
  def test_charts
    get :charts, { :group => @root_group.key }
    assert_response :success
  end
  
end
