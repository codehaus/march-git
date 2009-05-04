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


module RedactHelper
  require 'recaptcha'
  include ReCaptcha::ViewHelper
  
  def redact_email(text, mode = :html)
    results = []
    
    #there's some funny scoping thing going on, so we can't just yield to our own code atm.
    March::Email.match(text) { |t|
      if mode == :html
        mail_hide_simple(t)
      end
      
      if mode == :text
        t.gsub( /(.*)@([^\.]*).*/, '\1@\2...' )
      end
    }
  end

  def redact_email2(text, mode = :html)
    results = []
    
    #there's some funny scoping thing going on, so we can't just yield to our own code atm.
    March::Email.match2(text) { |type, value|
      results << [ type, value ]
    }
    
    redacted = ""
    for result in results
      type, value = result
      redacted << value if type == :text
      
      if mode == :html
        redacted << mail_hide(value) if type == :email
        next
      end
      
      if mode == :text
        redacted << value.gsub( /(.*)@([^\.]*).*/, '\1@\2...' ) if type == :email
        next
      end
    end
    return redacted
  end
  
  def redact_email_old(text)
    if not text
      logger.warn { "Some bastard is sending nils to redact_email, fix the caller, it's broken!" }
      #logger.warn { Kernel::caller.inspect }
      return ''
    end
    
    case ( text )
      when Array
        text.collect{|each|redact_email( each )}
      else
        text.gsub( /@([a-zA-Z0-9\-_]+)(\.[a-zA-Z0-9\-_]+)*(\.[a-zA-Z0-9\-_]+)/, '@\1\2...' )
    end
  end
end
