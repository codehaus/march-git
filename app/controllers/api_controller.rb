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
class ApiController < ApplicationController
  before_filter :filter_token
  
  def update_group
    identifier = params[:identifier]
    chunks = identifier.split('.')
    parent_identifier = chunks[0..-2].join('.')
    puts "Looking for parent: #{parent_identifier}"
    group_key = chunks.last
    
    if parent_identifier == ''
      parent = nil
      parent_id = nil
    else
      parent = Group.find_by_identifier(parent_identifier)
    
      if not parent
        render :status => 500, :text => 'Parent not found or not described'
        return
      end
      
      parent_id = parent.id
    end
    
    group = Group.find_by_parent_id_and_key(parent_id, group_key)
    
    if group
      puts "preexisting"
    else
      group = Group.new
      group.parent = parent
      group.identifier = identifier
      group.domain = parent.domain #default
      group.key = group_key
      group.save!
      GroupHierarchy.rebuild
    end
    
    if params[:domain]
      group.domain = params[:domain]
    end
    
    if params[:description]
      group.description = params[:description] 
    end
    
    if params[:url]
      group.url = params[:url]
    end
    
    group.save!
    
    att = group.attributes
    att.delete('id')
    render :text => att.to_yaml, :content_type => 'text/plain+yaml'
  end
  
  def update_list
    group_identifier = params[:group]
    group = Group.find_by_identifier(group_identifier)
    
    if not group
      render :status => 500, :text => 'Group not found or not described'
      return
    end
    
    list_identifier = params[:identifier]
    list = List.find_by_identifier(list_identifier)

    if list
      puts "preexisting"
    else
      list = List.new
      list.key = params[:key]
      list.group = group
      list.identifier = list_identifier
      list.address = params[:address]
      list.save!
    end
    
    if params[:description]
      list.description = params[:description] 
    end
    
    if not list.subscriber_address
      subscriber_host = group.subscriber_host
      vrp = Digest::SHA1.hexdigest( DateTime.now().to_s + rand( 42000 ).to_s + list.path )
      list.subscriber_address = "ar-#{vrp}@#{subscriber_host}"
    end
    
    list.save!
    
    att = list.attributes
    att.delete('id')
    render :text => att.to_yaml, :content_type => 'text/plain+yaml'
  end
  
private

  def acquire_parent(mandatory)
    @parent_identifier = params[:parent]
    if @parent_identifier
      @parent = Group.find_by_identifier(parent)
    end
    
    if mandatory and not @parent
      render :status => 500, :text => 'Parent not found or not described'
      return
    end
  end
  
  def filter_token
    token = params[:token]
    if not token
      render :status => 403, :text => 'Please supply a token'
      return false
    end

    if token.downcase != March::TOKEN.downcase
      render :status => 403, :text => 'Please supply a valid token'
      return false
    end
    
    return true
  end
end
