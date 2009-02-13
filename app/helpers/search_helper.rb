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

module SearchHelper
  def breadcrumbs()
    []
  end

  def search
    parse_query
    if not @postgres_search
      @messages = []
      return render( :template => '/search/index.html.erb' )
    end
    
    if @target
      cache( "search/#{@target.class.name}/#{@target.identifier}/#{@search_key}/#{latest_id}" ) do
        case @target
          when Group
            @messages = search_group(@target, @postgres_search)
          when List
            @messages = search_list(@target, @postgres_search)
        end

        return render( :template => '/search/index.html.erb' )
      end
    else
      cache( "search/all/0/#{@search_key}/#{latest_id}" ) do
        @messages = search_all(@postgres_search)
        return render( :template => '/search/index.html.erb' )
      end
    end
  end
  
private
  def parse_query
    @search = (params["search"])
    
    if @search.blank?
      @english_search = nil
      return false
    end
    
    @keywords = @search.downcase.split(' ')

    # The sort is to achieve a vague chance of caching a search result
    @postgres_search = @keywords.sort.join(' & ')
    @search_key = @keywords.sort.join('|')
    @english_search = @keywords.collect { |k| "<b>#{k}</b>" }.join(' AND ')
    
    logger.trace {"Searching for #{@postgres_search}"}
 end

  def search_list(target, searchterms)
    return Message.find_by_sql([ "SELECT * FROM sp_search_list(?, to_tsquery('march_config', ?))", target.id, searchterms ])
  end
 
 def search_group(target, searchterms)
   return Message.find_by_sql([ "SELECT * FROM sp_search_group(?, to_tsquery('march_config', ?))", target.id, searchterms ])
 end
 
 def search_all()
   #return Message.find_by_sql([ "SELECT * FROM sp_search_list(?, to_tsquery('march_config', ?))", target.id, searchterms)
 end
 
  
end
