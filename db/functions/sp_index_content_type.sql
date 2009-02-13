--------------------------------------------------------------------------------
--  Copyright 2006-2009 Codehaus Foundation
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--------------------------------------------------------------------------------

-- select * from sp_active_lists(2, 5) 
CREATE OR REPLACE FUNCTION sp_index_content_type(content_type VARCHAR(255)) RETURNS BOOLEAN AS $$
BEGIN
  RETURN SUBSTRING(content_type, 1, 10) = 'text/plain'
      OR SUBSTRING(content_type, 1, 9) = 'text/html';
END;
$$ LANGUAGE plpgsql;

