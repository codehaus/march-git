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

#Import single message files
#Commonly found in EZMLM archives
class March::FileMessageImporter
  attr_accessor :reload
  attr_accessor :max_threads
  
  def initialize
    @importer = March::MessageImporter.new
  end
  
  def import_files(filenames)
    index = 0
    messages = []
    
    count = filenames.length
    threads = []
    
    @importer.reload = reload
    
    while index < count do
      begin
        filename = filenames[index]
        
        if requires_load?(filename) 
          puts "Loading: #{filename}"
          if File.file?(filename)
            messages << import_file( filename, index, filenames.length )  
          end
        else
          puts "Skipping: #{filename}"
        end
        
      ensure
        index = index + 1
      end
    end
    messages
  end
  
  # Determines (based on various rules) whether a message needs to be loaded
  def requires_load?(filename)
    message = Message.find(:first, :conditions => ['source = ?', File.expand_path(filename) ])
    
    return true if not message
    return true if reload
    
    for part in message.parts
      return true if not part.content_id
    end
    
    return false
  end

  def import_file(filename, file_index = 0, file_count = 0)
    @importer.reload = reload
    if file_count == 0
      msg = "Importing #{filename}"
    else
      msg = "Importing #{filename} (#{file_index + 1}/#{file_count})"
    end
    puts msg
    logger.info(msg)
    content = read_file(filename)
    message = @importer.import_mail_from_content( content )
    
    if message
      message.source = File.expand_path(filename)
      message.save!
    end
    
    return message
  end
  
private
  def read_file(filename)
    File.open(filename) { |f|
      return f.read
    }
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end

end