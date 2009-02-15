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


class March::Email

  REGEX_EMAIL = Regexp.new('(.*?)([a-zA-Z0-9\-_]+@[a-zA-Z0-9\-_]+[\.a-zA-Z0-9\-_]+)(.*)')
  def self.match(text)
    if not text
      return ''
    end
    
    text.gsub(REGEX_EMAIL) { |t| yield(t) }
  end
  
  REGEX_EMAIL2 = Regexp.new('^(.*?)([a-zA-Z0-9\-_]+@[a-zA-Z0-9\-_]+[\.a-zA-Z0-9\-_]+)(.*)$', Regexp::MULTILINE)
  def self.match2(text)
    puts "Processing: #{text}"
    return '' if text.nil? or text.blank?
      
    #The block is passed two values; 
    #chunk_type = :text or :email
    #chunk_value = 'blah' or 'JIRA-334'
    msg = text
    match = REGEX_EMAIL2.match(msg)
    puts "PreMatch: #{match}"
    while (match)
      puts "match: #{$1} / #{$2} / #{$3}"
      pre = $1
      yield( :text, pre ) unless pre.blank?
      yield( :email, $2 )
      msg = $3
      match = REGEX_EMAIL2.match(msg)
    end

    yield(:text, msg) unless msg.blank?
  end
end