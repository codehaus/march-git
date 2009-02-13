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

CREATE OR REPLACE FUNCTION sp_message_is_spam(message_id INTEGER) RETURNS BOOLEAN AS $$
DECLARE
  current MESSAGES%rowtype;
BEGIN
  IF message_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  SELECT * INTO current FROM messages WHERE id = message_id;
  
  IF current.rating_total < 0 THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql;


