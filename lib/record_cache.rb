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


class RecordCache
  
  def initialize(records)
    @records = records
    @index_by = nil
  end
  
  def index_by(field)
    return if field == @index_by
    @index = {}
    for record in @records
      key = eval("record.#{field}")
      @index[key] ||= []
      @index[key] << record
    end
  end
  
  def get(key)
    return @index[key] || []
  end
  
  def empty?
    @records.empty?
  end
end