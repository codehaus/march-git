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

module CacheHelper
  def uptime_as_words(uptime)
    periods = [
      [ 60 * 60 * 24 * 365 , "year" ],
      [ 60 * 60 * 24 * 30 , "month" ],
      [ 60 * 60 * 24 * 7, "week" ],
      [ 60 * 60 * 24 , "day" ],
      [ 60 * 60 , "hour" ],
      [ 60 , "minute" ],
      [ 1 , "second" ]
    ]

    time = []

    # Loop trough all the chunks
    totaltime = 0
    for delta in periods
      seconds    = delta[0]
      name       = delta[1]

      count = ((uptime - totaltime) / seconds).floor
      time << pluralize(count, name) unless count == 0
      
      totaltime += count * seconds
    end

    "#{time.join(', ')}"
  end
end
