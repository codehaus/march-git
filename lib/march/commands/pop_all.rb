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

class March::Commands::PopAll
  include March::HeaderParser

  def self.run()
    options = {}
    ARGV.options do |opts|
      opts.on( '-r', '--root=<root>', String,
               'Storage root' ) do |root|
        options[:root] = root
      end
      opts.parse!
      options[:root] ||= March::MAIL_ROOT
    end

    groups = Group.find( :all, 
                         :conditions=>'pop_pass IS NOT NULL' )

    for group in groups
      group_queue = "#{March::MAIL_QUEUE}/#{group.path}"
      popper = March::Popper.new( group_queue, group )
      importer = March::MessageImporter.new( options[:root], [] )
      def importer.determine_list(headers)
        delivered_to = headers['delivered-to'][1]
        regexp = /(ar-[0-9a-f]+\@.*)$/
        if ( delivered_to =~ regexp )
          subscriber_address = $1
          return List.find_by_subscriber_address( subscriber_address )
        end
        nil
      end
      popper.pop_all do |message_path|
        importer.import( message_path )
      end
    end

    #importer = March::MessageImporter.new( options[:root], ARGV )
    #importer.import_all 
  end

end
