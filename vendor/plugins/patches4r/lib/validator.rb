################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

#Validates XHTML documents
class Validator
  
  def validate(filename)
    catalog = write_catalog
    ENV["SGML_CATALOG_FILES"] = catalog

    cmd = "xmllint --catalogs --noout --valid --nonet #{filename}"
    #puts cmd
    result = `#{cmd}`
    
    if $? != 0
      return result 
    else
      return nil
    end
  end
  
  def plugin_base_dir
    path = File.dirname(__FILE__) + "/.."
    File.expand_path(path)
  end

  def base_dir
    path = File.dirname(__FILE__) + "/../../../.."
    File.expand_path(path)
  end
  
  def write_catalog
    catalog_filename ="#{base_dir}/tmp/catalog"
    return catalog_filename if File.exists?(catalog_filename)

    Dir.mkdir "#{base_dir}/tmp/" unless File.exists?( "#{base_dir}/tmp/" )
    
    content = IO.readlines("#{plugin_base_dir}/dtd/catalog.tmpl").join()
    template = ERB.new(content)
    catalog = template.result(binding)

    File.open(catalog_filename, "w") { |io|
      io.write(catalog)
    }
    return catalog_filename
  end
end
