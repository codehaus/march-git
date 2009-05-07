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

require 'fileutils'
require 'find'

# Checks for headers on all ruby files
class CopyrightTest < ActionController::TestCase

  def test_rb
    base_path = File.expand_path(File.dirname(__FILE__) + '/../../')
    broken_paths = []
    skips = get_skips(base_path)
    Find.find(base_path) { |path| 
      Find.prune if File.basename(path) == ".svn"
      Find.prune if skips.include?(path)

      if File.file?(path)
        if File.basename(path)[-3..-1] == '.rb'
          broken_paths << path if not check_copyright(path)
        end
        
        if File.basename(path)[-5..-1] == '.rake'
          broken_paths << path if not check_copyright(path)
        end

        if File.basename(path)[-4..-1] == '.yml'
          broken_paths << path if not check_copyright(path)
        end
      end
    }
    
    assert_equal [], broken_paths
  end
  
private
  def check_copyright(path)
    actual = IO.readlines(path)
    expected = expected_copyright
    
    expected.each_index { |index|
      if expected[index].chomp != actual[index].chomp
        puts "#{path}: Mismatch on line #{index}"
        puts "  Expected: #{expected[index]}"
        puts "  Actual:   #{actual[index]}"
        return false
      end
    }
    return true
  end
  
  def expected_copyright
    chunk = <<-EOF
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
EOF
    return chunk.split("\n")
   end 
   
  def get_skips(base_path)
     skips = []
     skips << "#{base_path}/config/boot.rb"
     skips << "#{base_path}/config/deploy.rb"
     skips << "#{base_path}/vendor"
     skips << "#{base_path}/public/dispatch.rb"
     skips << "#{base_path}/db/schema.rb"
     skips << "#{base_path}/lib/tasks/capistrano.rake"
     skips << "#{base_path}/config/customer/codehaus/deploy.rb"
     skips << "#{base_path}/config/customer/muleforge/deploy.rb"
     skips << "#{base_path}/lib/march/rfc2047.rb"
     skips
  end
    
end
