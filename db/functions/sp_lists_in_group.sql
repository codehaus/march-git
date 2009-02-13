--------------------------------------------------------------------------------
--  Copyright 2007-2008 Codehaus Foundation
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
CREATE OR REPLACE FUNCTION sp_lists_in_group(p_group_id INTEGER) RETURNS SETOF lists AS $$
BEGIN
  IF p_group_id IS NULL THEN
    RETURN QUERY SELECT * FROM LISTS;
  ELSE
    RETURN QUERY 
      SELECT * 
      FROM lists
      WHERE group_id IN (
              SELECT CHILD_GROUP_ID 
              FROM GROUP_HIERARCHIES GH 
              WHERE GH.PARENT_GROUP_ID = p_group_id
            );
  END IF;
END;
$$ LANGUAGE plpgsql;


