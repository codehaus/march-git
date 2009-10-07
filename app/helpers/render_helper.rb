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

module RenderHelper
#  require 'recaptcha'
#  include ReCaptcha::ViewHelper

  def render_object(object, style = 'listing' )
    underscore_name = ActiveSupport::Inflector.underscore( object.class.name )
    render :partial=>"/by_object/#{underscore_name}/#{style}", :locals=>{ underscore_name.to_sym=>object } 
  end

  def render_part(part)
    case ( part.content_type.downcase )
      when /text\/html/  
        return render( :partial=>'/core/part_html', :object=>part )
      when /text\/plain/  
        return render( :partial=>'/core/part_plain', :object=>part )
      else
        return render( :partial=>'/core/part_plain', :object=>part )
    end
  end

  def render_part_attachment(title, part)
    return link_to( title, link_to_part(part) )
  end

  def render_message_tree(message)
    message_tree = message.first_message_in_thread
    messages = Message.find_by_sql( 
          [ "SELECT * FROM sp_get_thread(?,?,?)", 
            message_tree.list_id, 
            message_tree.message_id822, 
            5
          ])
    @message_cache = RecordCache.new(messages)
    
    render( :partial=>'/core/message_tree', :locals => { :message_tree => message_tree } )
  end

end
