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

-- select * from sp_latest_messages(94,25) order by sent_at desc limit 25;

CREATE OR REPLACE FUNCTION sp_latest_messages_for_group(pGROUP_ID INTEGER, pLIMIT INTEGER) RETURNS SETOF MESSAGES AS $$
DECLARE
  list LISTS%rowtype;
BEGIN
  -- For each list in the closure, grab the latest pLimit messages
  -- The caller will need to resort by sent_at and grab their limit of messages
  FOR list IN 
   SELECT L.ID 
    FROM GROUP_HIERARCHIES GH, LISTS L
    WHERE GH.PARENT_GROUP_ID = pGROUP_ID
      AND CHILD_GROUP_ID = L.GROUP_ID
  LOOP
    RETURN QUERY SELECT * 
                 FROM MESSAGES 
                 WHERE LIST_ID = LIST.ID 
                   AND SENT_AT > NOW() - INTERVAL '1 WEEK' -- Helps limit mega result sets due to inactive lists
                 ORDER BY SENT_AT DESC LIMIT pLIMIT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

