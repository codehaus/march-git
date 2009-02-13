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

-- One of the persistent risks is if you get multiple messages with the same message_id822 value. 

-- Extracts all messages in a thread - pass it the top message and the number of levels down 
-- you are interested in

CREATE OR REPLACE FUNCTION sp_get_thread(plist_id INTEGER, pmessage_id822 VARCHAR, pdepth INTEGER) RETURNS SETOF MESSAGES AS $$
DECLARE
  current MESSAGES%rowtype;
  child VARCHAR;
BEGIN
  SELECT * INTO current FROM MESSAGES WHERE list_id = plist_id AND message_id822 = pmessage_id822;
  IF current IS NULL THEN
    RETURN;
  END IF;
  
  RETURN NEXT current;
  
  IF pdepth = 0 THEN
    RETURN;
  END IF;

  FOR child IN 
   SELECT DISTINCT message_id822
    FROM messages
    WHERE list_id = plist_id
      AND in_reply_to_message_id822 = current.message_id822
  LOOP
    RETURN QUERY SELECT * FROM sp_get_thread(plist_id, child, pdepth - 1);
  END LOOP;
  
  RETURN;
END;
$$ LANGUAGE plpgsql;

