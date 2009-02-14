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

class ActivityController < ApplicationController
  def latest
  end
  
  def latest_data
    group = pather.target_group
    sql = <<EOF
  SELECT M.* 
  FROM MESSAGES M 
  WHERE LIST_ID IN (
    SELECT L.ID 
    FROM GROUP_HIERARCHIES GH, LISTS L
    WHERE GH.PARENT_GROUP_ID = #{group.id} 
      AND CHILD_GROUP_ID = L.GROUP_ID
    )
  ORDER BY M.ID DESC
  LIMIT 25
EOF
    @messages = Message.find_by_sql(sql)

    render :text => @messages.to_json
  end
  
end
