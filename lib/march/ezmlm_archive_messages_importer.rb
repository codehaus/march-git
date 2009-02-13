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
require 'find'

#Import single message files
#Commonly found in EZMLM archives
class March::EzmlmArchiveMessagesImporter
  
  def initialize(reload = false)
    @file_message_importer = March::FileMessageImporter.new
    @file_message_importer.reload = reload
  end
  
  
  def import_archives(dirs)
    messages = []
    for dir in dirs
      import_archive(dir)
    end
  end
  
  def import_archive(dir)
    files = []
    Find.find(dir) do |file|
      if file != dir
        Find.prune if not File.basename(file) =~ /^\d+$/
      end
      
      if File.file?(file)
        files << file
      end
    end
    
    files.sort!
    
    @file_message_importer.max_threads = 10
    @file_message_importer.import_files(files)
  end

end