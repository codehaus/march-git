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

class PartTest < ActiveSupport::TestCase
  fixtures :parts

  def test_charset
    part = Part.new
    part.content_type = 'text/html;'
    assert_equal nil, part.charset

    part.content_type = 'text/html; charset=UTF-8'
    assert_equal 'utf-8', part.charset

    part.content_type = 'text/html; charset=UTF-8; clown'
    assert_equal 'utf-8', part.charset

    part.content_type = 'text/html; charset=UTF-8;'
    assert_equal 'utf-8', part.charset
  end
end
