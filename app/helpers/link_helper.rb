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

class PageBlock
  attr_accessor :title
  attr_accessor :link
  attr_accessor :css_class

  def initialize(options)
    self.title = options[:title]
    self.link = options[:link]
    self.css_class = options[:css_class]
  end
  
  def as_html
    "<span class='#{ @css_class }'><a class='element #{ @css_class }' href='#{@link}'>#{ @title }</a></span>"
  end
  
end

class SplitBlock

  def initialize()
  
  end
  
  def as_html
    "<span class='element'>...</span>"
  end
  
end


module LinkHelper

  def fix_doubleslash(input)
    if input[0..1] == '//' 
      return input[1..-1]
    else
      return input
    end
  end
  
  def url_for_target(target, action = nil)
    if (action == :rss or action == :latest) and target.class == Message
      target = target.list
    end
      
    case target
      when Group
        return url_for_group(target, action)
      when List
        return url_for_list(target, action)
      when Message
        return url_for_message(target, action)
      else
        return nil
    end
  end

  def url_for_message( message, action = nil)
    action ||= :index
    return url_for( :controller => 'messages', 
                    :list => message.list.identifier, 
                    :message => message.message_id822,
                    :action => action )
  end

  def url_for_message_content( message )
    return url_for_message(message) + '/content'
  end

  def url_for_part( part, download = false )
    if download
      url_for_message(part.message) + "/#{ part.message.parts.index(part) }/~download"
    else
      url_for_message(part.message) + "/#{ part.message.parts.index(part) }"
    end
  end
  


  def url_for_group( group, action = nil)
    action ||= :index
    return url_for( :controller => 'groups', :group => group.identifier, :action => action )
  end

  def url_for_list( list, action = nil )
    action ||= :info
    return url_for( :controller => 'lists', :list => list.identifier, :action => action )
  end

  def link_to_message( link_text, message )
    link_to link_text, url_for_message( message ), { :title => message.subject }
  end

  def link_to_part( link_text, part, download = false )
    link_to link_text, url_for_part( part, download ), { :title => part.content_type }
  end
  
  def link_to_group( link_text, group )
    link_to link_text, url_for_group( group ), { :title => group.name }
  end

  def link_to_list( link_text, list )
    link_to link_text, url_for_list( list ), { :title => list.address }
  end
  
  def link_to_charts( link, link_title )
    img = image_tag("chart.gif", :class => 'feed-link')
    link_to img, link, :title => link_title
  end

  def link_to_rss( link, link_title )
    img = image_tag("feed-icon-16x16.png", :class => 'feed-link')
    link_to img, link, :title => link_title
  end

  def message_pagination(paginator)
    @page_blocks = []
    params = {}
    first        = paginator.first
    last         = paginator.last
    current_page = paginator.current_page
    window_pages = current_page.window(5).pages
    
    if not (wp_first = window_pages[0]).first?
      params[:page] = first.number
      @page_blocks << PageBlock.new(:title => first.number.to_s, :link => url_for( params ), :css_class => '' )
      @page_blocks << SplitBlock.new() if wp_first.number - first.number > 1
    end
    
    for page in window_pages
      params[:page] = page.number
      if ( page.number == current_page.number )
        @page_blocks << PageBlock.new( :title => page.number.to_s, :link => url_for(params), :css_class => 'current_page')
      else
        @page_blocks << PageBlock.new( :title => page.number.to_s, :link => url_for(params), :css_class => '')
      end
    end

    
    if not (wp_last = window_pages[-1]).last?
      params[:page] = last.number
      @page_blocks << SplitBlock.new() if last.number - wp_last.number > 1
      @page_blocks << PageBlock.new(:title => last.number.to_s, :link => url_for( params ), :css_class=>'' )
    end
    
    render( :partial => '/core/message_paginator' )
  end
  
  
private
  #Based on our current context (@pather.root), potentially need to chop some elements off any link we are passing back to the page
  #For instance, if we are currently under haus/drools, then a link to haus/drools/dev would be reconciled to /dev
  def reconcile_path(path)
    return path
    #redundant after layout change
    #logger.debug { "Reconciling #{path} against root of #{@pather.root}" }
    #out = path.gsub( /^#{@pather.root}/, '' )
    #out += '/' if out[-1..-1] != '/'
    #return out
  end
end
