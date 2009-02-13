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

class EmailHeaderTest < Test::Unit::TestCase

  FROM_DATA = [
    [ '"Bob McWhirter" <bob@fnokd.com>', 'Bob McWhirter', 'bob@fnokd.com' ],
    [ 'Bob McWhirter <bob@fnokd.com>',   'Bob McWhirter', 'bob@fnokd.com' ],
    [ 'bob@fnokd.com',                   'bob@fnokd.com', 'bob@fnokd.com' ],
  ]

  REF1 = '20041126032158.12395.qmail@codehaus.org'
  REF2 = '94ABA344-3FC7-11D9-9C4C-000A95C4F656@cantilevertech.com'
  REF3 = '41A774FC.2060705@codehaus.org'
  REF4 = '41A7A833.1060208@codehaus.org'

  def test_direct_access
    header = March::EmailHeader.new(
      'subject'=>['This is the subject']
    )
    assert_equal 'This is the subject', header['subject'][0]
  end
 
  def test_subject
    header = March::EmailHeader.new(
      'subject'=>['This is the subject']
    )
    assert_equal 'This is the subject', header.subject
  end

  def test_from
    for data in FROM_DATA
      actual, name, address = data
      header = March::EmailHeader.new( 'from'=>[ actual ] )
      assert_equal actual, header.from
      assert_equal name, header.from_name
      assert_equal address, header.from_address
    end
  end

  def test_references
    header = March::EmailHeader.new( 'references'=> [ "<#{REF1}>" ] )
    assert_equal 1, header.references.size
    assert header.references.include?( REF1 )

    header = March::EmailHeader.new( 'references'=> [ "<#{REF1}> <#{REF2}>" ] )
    assert_equal 2, header.references.size
    assert header.references.include?( REF1 )
    assert header.references.include?( REF2 )

    header = March::EmailHeader.new( 'references'=> [ "<#{REF1}>", "<#{REF2}>" ] )
    assert_equal 2, header.references.size
    assert header.references.include?( REF1 )
    assert header.references.include?( REF2 )

    header = March::EmailHeader.new( 'references'=> [ "<#{REF1}> <#{REF2}>", "<#{REF3}> <#{REF4}>" ] )
    assert_equal 4, header.references.size
    assert header.references.include?( REF1 )
    assert header.references.include?( REF2 )
    assert header.references.include?( REF3 )
    assert header.references.include?( REF4 )
  end

  def test_in_reply_to
    header = March::EmailHeader.new( 'in-reply-to'=>[ "<#{REF1}>" ] )
    assert_equal "<#{REF1}>", header['in-reply-to'][0]
    assert_equal REF1, header.in_reply_to
  end

  def test_message_id
    header = March::EmailHeader.new( 'message-id'=>[ "<#{REF1}>" ] )
    assert_equal REF1, header.message_id

    header = March::EmailHeader.new( {} )
    assert header.message_id =~ /@.*march\.rubyhaus\.org$/
  end
end
