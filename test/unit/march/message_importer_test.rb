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

require File.dirname(__FILE__) + '/../../test_helper'

class March::MessageImporterTest < ActiveSupport::TestCase
  all_fixtures
  
  def test_import_01
    msg = load_message('40AFC282.4060101@nrfx.com', 'msg-01.txt', false)
  end

  def test_import_02
    msg = load_message('20070203112356.5969.qmail@mail.codehaus.org', 'msg-02.txt', false)
  end

  def test_import_03
    msg = load_message('414021E3.8060309@codehaus.org', 'msg-03.txt', false)

    parts = msg.parts
    
    assert_equal 3, parts.length
    assert_equal 'text/html', msg.content_part.content_type

    msg = load_message('414021E3.8060309@codehaus.org', 'msg-03.txt', true)
  end

  def test_import_04
    #Synthetic message id
    message_id = Message.synthetic_message_id822(
          'archive.codehaus.org', 
          DateTime.new(2008, 1, 10, 14, 52, 38), 
          'AW: AW: [m2eclipse-user] m2Eclipse plugin remains unusable without install support'
    )
    
    puts "Synthesised Message-Id: #{message_id}"
    
    msg = load_message(message_id, 'msg-04.txt', false)
  end
  
private
  #Loads a message and checks that what it loaded is what it was supposed to load.
  #Returns the AR Object for the Message
  def load_message(message_id822, name, existing)
    
    assert_nil Message.find_by_message_id822(message_id822) if not existing
    assert_not_nil Message.find_by_message_id822(message_id822) if existing
    
    mi = March::FileMessageImporter.new
    mi.reload = true
    
    msg = mi.import_file(File.dirname(__FILE__) + "/#{name}")
    assert_not_nil msg, 'message should be imported'
    assert_not_nil msg.parts, 'there should be at least 1 part'
    assert_equal message_id822, msg.message_id822
    assert_equal msg, Message.find_by_message_id822(message_id822)
    assert_not_nil msg.content_part, "content_part should be set during load"
    return msg
  end
end
