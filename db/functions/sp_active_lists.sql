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

-- select * from sp_active_lists(2, 5) 
CREATE OR REPLACE FUNCTION sp_active_lists(pGROUP_ID INTEGER, pLIMIT INTEGER) RETURNS SETOF LISTS AS $$
DECLARE
  list_id INTEGER;
  list LISTS%ROWTYPE;
  max_message_id INTEGER;
BEGIN
  SELECT MAX(id) INTO max_message_id FROM messages;
  RAISE NOTICE 'Limit is %', pLIMIT;
  RAISE NOTICE 'Latest message is %', max_message_id;
  
  -- Look for all lists active in the last 500 messages; then sort by descending order
  -- This will be confused by a bulk loader running; but will be quickly fixed as new messages come through
  FOR list_id IN
     SELECT L.ID
      FROM GROUP_HIERARCHIES GH, LISTS L, MESSAGES M
      WHERE GH.PARENT_GROUP_ID = pGROUP_ID
        AND CHILD_GROUP_ID = L.GROUP_ID
        AND L.ID = M.LIST_ID
        AND M.ID >= (max_message_id - 500)
      GROUP BY L.ID
      ORDER BY COUNT(*) DESC
  LOOP
    SELECT * INTO list FROM LISTS L WHERE L.ID = list_id;
    RETURN NEXT list;
  END LOOP;
  
  RETURN;
END;
$$ LANGUAGE plpgsql;

