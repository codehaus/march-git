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
      return render( :template => '/search/index.html.haml' )
    end
    
    if @target
      cache( "search/#{@target.class.name}/#{@target.identifier}/#{@search_key}/#{latest_id}" ) do
        @worker_key = generate_worker_key()
        @job_key = generate_worker_key()
        
        #@actual_worker_key = MiddleMan.new_worker(:worker => :search_worker)
                                #:worker_key => @worker_key)
        @worker = MiddleMan.worker(:search_worker)#, @actual_worker_key)
        case @target
          when Group
            @worker.enq_search_group(:job_key => @job_key, :args => [ @postgres_search, @target.id ]) 
            #flash[:warnings] << "Your search has been queued (#{@worker_key})!"
          when List
            @worker.enq_search_list(:job_key => @job_key, :args => [ @postgres_search, @target.id ]) 
            #flash[:warnings] << "Your search has been queued (#{@worker_key})!"
        end

        return render( :template => '/search/index' )
      end
    else
      cache( "search/all/0/#{@search_key}/#{latest_id}" ) do
        @worker.enq_search_all(:args => [ @postgres_search ]) 
        return render( :template => '/search/index' )
      end
    end
  end
  
  def search_results
    @worker = MiddleMan.worker(:search_worker)#, @worker_key)

    @worker_key = params[:worker_key]
    @job_key = params[:job_key]
    @worker_info = @worker.worker_info 
    
    puts @worker_info.inspect
    
    if request.xhr?
      message_ids = @worker.ask_result(@job_key + '_results')
      
      render :update do |page|
        if not message_ids.nil?
          @messages = message_ids.collect { |id| Message.find(id) }
          content = render( :partial => '/search/search_results', :locals => { :messages => @messages } )
          page.remove('spinner')
          page.call('stop_xhr')
          page.replace_html 'search-results', content
        else
          content = render( :partial => '/search/search_status', :locals => { :all_worker_info => MiddleMan.all_worker_info } )
          page.replace_html 'search-results', content
        end
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

 
  def generate_worker_key
    length = 16
    bytes = OpenSSL::Random.random_bytes(16 / 2)

    result = ""
    bytes.each_byte { |b|
      result << sprintf("%02x", b)  
    }

    return result
  end 
  
end
