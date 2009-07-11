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
module GroupsHelper
  include TagHelper
  
  def tags(group)
      sql = <<EOF
  SELECT * from 
    ts_stat('select data_tsv 
             from contents 
             where list_id IN (
               SELECT id FROM LISTS WHERE GROUP_ID = #{group.id}
             ) order by id desc limit 1000') ts
  WHERE NOT EXISTS (SELECT * FROM stop_words sw WHERE sw.word = ts.word)
    AND char_length(word) > 3
    AND word not like '%/%'
  order by ndoc desc, nentry desc, word limit 60;
EOF
#SELECT ID FROM sp_lists_in_group(#{group.id})
    return Group.find_by_sql(sql)
  end
  
end
