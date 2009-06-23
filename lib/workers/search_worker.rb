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

class SearchWorker < BackgrounDRb::MetaWorker
  set_worker_name :search_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def search_list(args)
    searchterms = args[0]
    list_id = args[1]
    result = Message.find_by_sql([ "SELECT * FROM sp_search_list(?, to_tsquery('march_config', ?))", list_id, searchterms ])
    trace "search_list complete - #{searchterms}"
    cache[job_key() + '_results'] = result.collect { |m| m.id }
    return result
  end
  
  def search_group(args)
    searchterms = args[0]
    group_id = args[1]
    result = Message.find_by_sql([ "SELECT * FROM sp_search_group(?, to_tsquery('march_config', ?))", group_id, searchterms ])
    trace "search_group complete - #{searchterms}"
    cache[job_key() + '_results'] = result.collect { |m| m.id }
    return result
  end
  
  def search_all(args)
    searchterms = args[0]
    result = Message.find_by_sql([ "SELECT * FROM sp_search_all(to_tsquery('march_config', ?))", searchterms ])
    trace "search_all complete - #{searchterms}"
    cache[job_key() + '_results'] = result.collect { |m| m.id }
    return result
  end
  
  def trace(msg)
    puts "#{job_key()}: #{msg}"
  end
  
end

