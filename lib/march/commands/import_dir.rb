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

require 'find'
require 'pp'
require 'optparse'
require 'time'

class March::Commands::ImportDir

  def self.run()
    files = []
    for path in ARGV
      files << get_files(path)
    end
    files.flatten!
    runner = March::Commands::ImportDir.new( files )
    runner.run
  end
  
  def self.get_files(dir)
    files = []
    
    Find.find(dir) { |path|
      if File.directory?(path) 
        logger.info "Scanning down into #{path}"
      end
      
      if File.file?(path)
        files << path
      end
    }
    return files
  end

  def initialize(files)
    @files = files
  end

  def run()
    importer = March::FileMessageImporter.new
    importer.import_files(@files)
  end
  
protected 
  def self.logger
    RAILS_DEFAULT_LOGGER    
  end

end
