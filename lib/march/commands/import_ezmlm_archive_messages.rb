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

require 'pp'
require 'optparse'
require 'time'

require 'march/commands/import_message'


class March::Commands::ImportEzmlmArchiveMessages
  include March::HeaderParser

  def self.run()
    options = {}
    options[:reload] = false
    
    ARGV.options do |opts|
      opts.on( '-r', '--reload', String, 'Reload messages that are already loaded' ) do |reload|
        puts "Reloading files"
        options[:reload] = true
      end
      opts.parse!
      raise "import files must be specified" unless ARGV.size > 0 
    end

    importer = March::EzmlmArchiveMessagesImporter.new( options[:reload] )
    importer.import_archives(ARGV)
  end

end
