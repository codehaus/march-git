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

class ImportTest < ActionController::TestCase
  all_fixtures

  def test_user_milyn_codehaus_org_02
    import_file('user@milyn.codehaus.org-02')
  end

  def test_user_milyn_codehaus_org_06
    import_file('user@milyn.codehaus.org-06')
  end
  

private
  def import_file(filename)
    fullname =  "#{RAILS_ROOT}/test/messages/#{filename}"
    
    content = IO.read(fullname)
    
    mi = March::MessageImporter.new
    
    message = mi.import_mail_from_content(content)
    assert_not_nil message
    
  end
end
