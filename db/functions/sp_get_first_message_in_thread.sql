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

-- select * from sp_latest_messages(94,25) order by sent_at desc limit 25;

CREATE OR REPLACE FUNCTION sp_get_first_message_in_thread(pMESSAGE_ID INTEGER) RETURNS SETOF MESSAGES AS $$
DECLARE
  current MESSAGES%rowtype;
  parent MESSAGES%rowtype;
  depth INTEGER;
BEGIN
  depth := 0;
  
  SELECT * INTO current FROM MESSAGES WHERE ID = pMESSAGE_ID;
  
  IF current IS NULL THEN
    RETURN;
  END IF;
  
  
  FOR depth in 1..10 LOOP
    IF current.in_reply_to_message_id822 IS NULL THEN
      RETURN NEXT current;
      RETURN;
    END IF;
    
    SELECT * INTO parent 
    FROM MESSAGES 
    WHERE message_id822 = current.in_reply_to_message_id822
      AND list_id = current.list_id
    LIMIT 1;
    
    IF parent IS NULL THEN
      RETURN NEXT current;
      RETURN;
    END IF;
    
    current := parent;
  END LOOP;
  
  RETURN NEXT current;
  RETURN;

END;
$$ LANGUAGE plpgsql;

