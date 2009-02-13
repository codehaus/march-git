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

-- Keeps the list_id / message_id fields on the contents table up-to-date
-- Client code does not need to update these fields unless they do something nasty!
CREATE OR REPLACE FUNCTION trg_contents_denormalization() RETURNS trigger AS $$
DECLARE
BEGIN
  SET MAINTENANCE_WORK_MEM = '1GB';
  IF new.message_id IS NULL THEN
    SELECT message_id INTO new.message_id FROM parts WHERE content_id = new.id;
  END IF;
  
  IF new.list_id IS NULL THEN
    SELECT list_id INTO new.list_id FROM messages WHERE id = new.message_id;
  END IF;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql;