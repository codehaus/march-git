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

class March::HtmlCleanerTest < Test::Unit::TestCase
  
  def setup
    @cleaner = March::HtmlCleaner.new
  end
    
  #Tests basic ruby configuration
  def test_01
    test_clean("01")
  end
  
  #Tests that divs are left alone
  def test_02
    test_clean("02")
  end
  
  #Tests that javascript actions are stripped
  def test_03
    test_clean("03")
  end
  
  #Tests that bad HTML is fixed
  def test_04
    test_clean("04")
  end

  #Tests that bad HTML is fixed
  #XXX test hangs
  #def test_05
  #  test_clean("05")
  #end
  
  #This is some weird Office mail format sent by crazed frenchmen
  #Checks that the ifs inside <head> are stripped out
  def test_06
    test_clean("06")
  end

  #This is some weird Office mail format sent by crazed frenchmen
  #Checks that the multiline ifs inside <head> are stripped out
  def test_07
    test_clean("07")
  end

  #This is some weird Office mail format sent by crazed frenchmen
  #Checks that the ifs inside <body> are stripped out
  def test_08
    test_clean("08")
  end
  
  def test_strip_ifs
    assert_equal '', @cleaner.strip_ifs('<![endif]>')
    assert_equal '', @cleaner.strip_ifs('<![if !supportLists]>')
  end
  
private
  def test_clean(suffix)
    input = IO.read(File.dirname(__FILE__) + "/html_cleaner_test_#{suffix}_input.txt")
    expected = IO.read(File.dirname(__FILE__) + "/html_cleaner_test_#{suffix}_expected.txt")
  
    actual = @cleaner.clean(input)
    #puts actual
    assert_equal expected, actual
  end
end