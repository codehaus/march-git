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

class MessageTest < Test::Unit::TestCase
  all_fixtures

  def test_normalize_message_id822
    assert_equal 'abcd', Message.normalize_message_id822('abcd')
    assert_equal 'abcd', Message.normalize_message_id822('ab%cd')
    assert_equal 'abcd', Message.normalize_message_id822('a/b/%/c/d')
    assert_equal 'UENERkVCMDkAAQACAAAAAAAAAAAAAAAAABgAAAAAAAAAGaOSqd7KU0GrwP9RZsAKucKAAAAQAAAAMKPIh1M2c0GwQj5EMDv1YQEAAAAA@locken.fr', Message.normalize_message_id822('!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAABgAAAAAAAAAGaOSqd7KU0GrwP9RZsAKucKAAAAQAAAAMKPIh1M2c0GwQj5EMDv1YQEAAAAA@locken.fr')
    assert_equal '', Message.normalize_message_id822('')
    assert_equal nil, Message.normalize_message_id822(nil)
  end
  
  def test_before_save
    m = Message.new
    m.message_id822 = "a%b.com"
    m.list = List.find(:first)
    m.sent_at = Time.now
    m.from_address = 'clown@example.com'
    m.from_header = 'clown@example.com'
    m.save!

    assert_equal 'ab.com', m.message_id822    
  end
  
  
  def test_extract_name
    assert_nil Message.extract_name(nil)
    assert_equal 'Bert', Message.extract_name('Bert <bert@beetle>')
  end
  
  def test_process_from_header
    test_process_from_header_internal('Bert <bert@example.com>', 'Bert <bert@example.com>', 'bert@example.com', 'Bert')
    test_process_from_header_internal('bert@example.com', 'bert@example.com', 'bert@example.com', nil)
    test_process_from_header_internal('"Bert" <bert@example.com>', '"Bert" <bert@example.com>', 'bert@example.com', 'Bert')
  end
  
  def test_process_from_header_internal(input_from_header, from_header, from_address, from_name)
    m = Message.new
    m.process_from_header(input_from_header)
    assert_equal from_header, m.from_header
    assert_equal from_address, m.from_address
    assert_equal from_name, m.from_name
  end
  
  def test_subject_precis
    m = Message.new
    m.subject = "ABCDEFGHIJ" * 10
    assert "ABCDE...", m.subject_precis( 5 )
    assert m.subject, m.subject_precis( 120 )
  end
  
end
