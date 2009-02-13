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
CREATE OR REPLACE FUNCTION sp_populate_counts() RETURNS VOID AS $$
DECLARE
  group groups%ROWTYPE;
  list  lists%ROWTYPE;
BEGIN

  FOR group IN SELECT * FROM groups
  LOOP
    RAISE NOTICE ' Processing group %', group.identifier;
    UPDATE groups
       SET children_count = (SELECT COUNT(*) FROM groups WHERE parent_id = group.id),
           lists_count = (SELECT COUNT(*) FROM lists WHERE group_id = group.id)
     WHERE id = group.id;
  END LOOP;  

  FOR list IN SELECT * FROM lists
  LOOP
    RAISE NOTICE ' Processing list %', list.identifier;
    UPDATE lists
       SET messages_count = (SELECT COUNT(*) FROM messages WHERE list_id = list.id)
     WHERE id = list.id;
  END LOOP;  
  RETURN;
END;
$$ LANGUAGE plpgsql;


