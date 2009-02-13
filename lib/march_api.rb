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

class MarchGroup < ActionWebService::Struct
  member :path, :string
  member :parent, :string
  member :key,  :string
end
  
class MarchList < ActionWebService::Struct
  member :group,              :string
  member :key,                :string
  member :address,            :string
  member :subscriber_address, :string
end

class MarchApi < ActionWebService::API::Base

  api_method :login,
             :expects=>[{:username=>:string},
                        {:password=>:string}],
             :returns=>[:string] # -> token

  api_method :logout,
             :expects=>[{:token=>:string}]

  api_method :find_group,
             :expects=>[{:token=>:string},
                        {:group_path=>:string}],
             :returns=>[MarchGroup] # -> group

  api_method :root_groups,
             :expects=>[{:token=>:string}],  # token
             :returns=>[[MarchGroup]] # -> root groups

  api_method :list_subgroups,
             :expects=>[{:token=>:string},
                        {:group_path=>:string}],
             :returns=>[[MarchGroup]] # -> root group

  api_method :new_group,
             :expects=>[{:token=>:string},
                        {:parent_path=>:string},
                        {:key=>:string},
                        {:name=>:string},
                        {:url=>:string},
                        {:domain=>:string}],
             :returns=>[MarchGroup] # -> new group

  api_method :update_group,
             :expects=>[{:token=>:string},
                        {:parent_path=>:string},
                        {:key=>:string},
                        {:name=>:string},
                        {:url=>:string},
                        {:domain=>:string}],
             :returns=>[MarchGroup] # -> new group

  api_method :list_lists,
             :expects=>[{:token=>:string},
                        {:group_path=>:string}],
             :returns=>[[MarchList]] # -> the lists

  api_method :new_list,
             :expects=>[{:token=>:string},
                        {:group_path=>:string},
                        {:key=>:string},
                        {:address=>:string},
                        {:url=>:string}],
             :returns=>[MarchList] # -> new list

  api_method :update_list,
             :expects=>[{:token=>:string},
                        {:group_path=>:string},
                        {:key=>:string},
                        {:address=>:string},
                        {:url=>:string}],
             :returns=>[MarchList] # -> updated list

  api_method :find_list,
             :expects=>[{:token=>:string},
                        {:list_path=>:string}],
             :returns=>[MarchList] # -> the list

end
