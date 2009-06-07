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
ActionController::Routing::Routes.draw do |map|

  map.connect '/',
    :controller => 'home'
    
  map.connect '/m/:message',
    :controller => 'messages',
    :action => 'permlink'
    
  map.connect '/api/:action',
    :controller => 'api'

  map.connect '/my/:action',
    :controller => 'my'
    
  map.connect '/favorites/:action',
    :controller => 'favorites'
    
  map.connect '/auth/:action',
    :controller => 'auth'

  map.connect '/zeitgeist/:action',
    :controller => 'zeitgeist'

  map.connect '/cache/:action',
      :controller => 'cache'

  map.connect '/groups',
    :controller => 'groups',
    :action => 'index'

  map.connect '/groups/:group/:action',
    :controller => 'groups',
    :requirements => { :group => /[a-z0-9\.\-\@]+/i }
    
  map.connect '/search',
    :controller => 'search'

  map.connect '/lists',
    :controller => 'lists',
    :action => 'index'

  map.connect '/lists/:list',
    :controller => 'lists',
    :action => 'info',
    :requirements => { :list => /[a-z0-9\.\-\@]+/ }

  map.connect '/lists/:list/:action',
    :controller => 'lists',
    :requirements => { :list => /[a-z0-9\.\-\@]+/ }

  map.connect '/lists/:list/msg/:message',
    :controller => 'messages',
    :action => 'index',
    :requirements => { :list => /[^\/]+/, :message => /[^\/]*/ }

  # For downloading parts off a message
  map.connect '/lists/:list/msg/:message/:action/:pos',
    :controller => 'messages',
    :requirements => { :list => /[^\/]+/, :message => /[^\/]*/ }
    

  map.connect '/ratings/:action/:message_id',
    :controller => 'ratings'
    
  map.connect '/march/:action', 
    :controller => 'march'
    
  map.connect 'sitemap',
    :controller => 'sitemap',
    :action => 'index'

  map.connect 'sitemap/',
    :controller => 'sitemap',
    :action => 'list'
    
  map.connect '~gestalt/:action',
    :controller=>'gestalt'

  map.connect '*path',
    :controller=>'core'

end
