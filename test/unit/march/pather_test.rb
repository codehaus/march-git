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

require File.dirname(__FILE__) + '/../../test_helper'

class March::PatherTest < Test::Unit::TestCase
  all_fixtures
  
  def test_groups
    test_wrapper( false, '', 'goo', nil, nil, nil )
    test_wrapper( false, 'haus', 'codehaus', Group.find_by_path('haus/codehaus'), nil, nil )
    test_wrapper( false, 'haus', 'codehaus/drools', Group.find_by_path('haus/codehaus/drools'), nil, nil )
    test_wrapper( false, 'haus', 'codehaus/drools/', Group.find_by_path('haus/codehaus/drools'), nil, nil )
    test_wrapper( false, 'haus', 'codehaus/drools/dev', List.find_by_address('dev@drools.codehaus.org'), nil, nil )
    test_wrapper( false, 'haus', 'codehaus/drools/dev/', List.find_by_address('dev@drools.codehaus.org'), nil, nil )
  end
  
  def test_groups_with_action
    test_wrapper( false, 'haus', 'codehaus/drools/dev/rss', List.find_by_address('dev@drools.codehaus.org'), :rss, [] )
  end
  
  def test_messages
    assert_not_nil Message.find_by_message_id822('goo-20060713200832@fnert.lard.com')
    test_wrapper( false, 'haus', 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com', Message.find_by_message_id822('goo-20060713200832@fnert.lard.com'), nil, nil )
  end
  
  def test_parts
    msg = Message.find_by_message_id822('goo-20060713200832@fnert.lard.com')
    test_wrapper( false, 'haus', 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com/0', msg.parts[0], nil, nil )
    test_wrapper( false, 'haus', 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com/1', msg.parts[1], nil, nil )
  end

  def test_parts_download
    msg = Message.find_by_message_id822('goo-20060713200832@fnert.lard.com')
    test_wrapper( false, 'haus', 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com/0/~download', msg.parts[0], :download, [] )
    test_wrapper( false, 'haus', 'codehaus/drools/dev/goo-20060713200832@fnert.lard.com/1/~download', msg.parts[1], :download, [] )
  end
  
private
  def create_request(params)
    request = March::Request.new
    request.parameters = params
    request
  end

  def test_wrapper( debug, root, path, target, action, action_segments )
    path = path.split('/')
    pre_path = [].concat(path)
    pather = March::Pather.new(root, path, debug)
    assert_equal pre_path, path, 'path' #We had a bug once upon a time that cleared the input array due to shoddy code
    assert_equal target, pather.target, 'target'
    assert_equal action, pather.action, 'action'
    assert_equal action_segments, pather.action_segments, 'action_segments'
  end
  

end



class March::Request
  attr_accessor :parameters
end
