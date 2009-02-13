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

module ListsHelper
  include TagHelper
  
  
  def tags(list)
      sql = <<EOF
  SELECT * from ts_stat('select data_tsv from contents where list_id = #{list.id} order by id desc limit 1000') ts
  WHERE NOT EXISTS (SELECT * FROM stop_words sw WHERE sw.word = ts.word)
  order by ndoc desc, nentry desc,word limit 100;
EOF

    return Message.find_by_sql(sql)
  end
  
private
  
  
end
