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


def try_gem(name, comparator = nil, version = nil)
  begin
    if comparator
      gem name, comparator + ' ' + version
    else
      gem name
    end
    return false
  rescue Exception => e
    puts "Problem loading gem #{name} with version #{comparator} #{version}"
    puts "try:"
    puts " gem install -v #{version} #{name}"
    return true
  end
end


puts "Checking gem versions..."

gems_failed = false
gems_failed ||= try_gem( 'tidy',                 '>=', '1.1.2' )
gems_failed ||= try_gem( 'htmlentities',         '>=', '4.0.0' )
gems_failed ||= try_gem( 'ci_reporter',          '>=', '1.5.1'   )
#gems_failed ||= try_gem( 'soap4r',               '>=', '1.5.8' )
gems_failed ||= try_gem( 'rcov' )
gems_failed ||= try_gem( 'postgres')
gems_failed ||= try_gem( 'ruby-openid')
gems_failed ||= try_gem( 'recaptcha')
#gem install --source http://www.loonsoft.com/recaptcha/pkg/ recaptcha

gems_failed ||= try_gem( 'chronic')
gems_failed ||= try_gem( 'memcache-client',      '=', '1.5.0' )

if gems_failed
  exit 1
else
  puts "Gem versions verified."
end
