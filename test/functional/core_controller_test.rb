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
require 'core_controller'

# Re-raise errors caught by the controller.
class CoreController; def rescue_action(e) raise e end; end

class CoreControllerTest < ActionController::TestCase
  all_fixtures
  
  def setup
    @controller = CoreController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_group_target
    group = Group.find_by_domain('archives.drools.codehaus.org')
    get :index, { :path => 'codehaus/drools'.split('/'), :root => 'haus' }
    
    pather = @controller.pather
    
    assert_not_nil pather
    assert_equal group, pather.target
    assert_nil pather.action
    assert_nil pather.action_segments
  end

  def test_list_target
    log_test_banner("Starting test_list_target")
    
    list = List.find_by_address('dev@drools.codehaus.org')
    
    get :index, { :path => 'codehaus/drools/dev'.split('/'), :root => 'haus' }
    
    pather = @controller.pather
    
    assert_not_nil pather
    assert_equal list, pather.target
    assert_nil pather.action
    assert_nil pather.action_segments
  end
  
  def test_message_target
    log_test_banner("Starting test_message_target")
    
    message = Message.find_by_message_id822('goo-20060713200832@fnert.lard.com')
    
    get :index, { :path => 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com'.split('/'), :root => 'haus' }
    
    pather = @controller.pather
    
    assert_not_nil pather
    assert_equal message, pather.target
    assert_nil pather.action
    assert_nil pather.action_segments
  end

  def test_latest_for_list
    log_test_banner("Starting test_list_target")
    
    list = List.find_by_address('dev@drools.codehaus.org')
    
    get :index, { :path => 'codehaus/drools/dev/~latest/rss'.split('/'), :root => 'haus' }
    
    pather = @controller.pather
    
    assert_not_nil pather
    assert_equal list, pather.target
    assert_equal :latest, pather.action
    assert_equal [ "rss" ], pather.action_segments
  end
end
