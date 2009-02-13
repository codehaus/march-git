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

# Similar to the Google Zeitgeist, the March Zeitgeist distills terms from the latest
# #N messages.
class ZeitgeistController < ApplicationController
  
  def subjects
    @messages = 100
    @type = :subjects
    @sql = <<EOF
select * from ts_stat('select subject_tsv FROM messages order by id desc limit #{@messages}') ts
where not exists (select * from ignorewords iw where ts.word::varchar = iw.word)
order by ndoc desc, nentry desc,word limit 10;
EOF
    render :template => '/zeitgeist/zeitgeist.rxml', :layout => false
  end
end
