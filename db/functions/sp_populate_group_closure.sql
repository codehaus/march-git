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
/*
\i db/functions/sp_populate_group_closure.sql 
select sp_populate_group_closure();
select * from group_hierarchies;
*/

CREATE OR REPLACE FUNCTION sp_populate_group_closure() RETURNS void AS $$
DECLARE closure_distance int;
BEGIN
TRUNCATE TABLE GROUP_HIERARCHIES;

-- Seed the closure table with top-level groups
INSERT INTO GROUP_HIERARCHIES
( PARENT_GROUP_ID, PARENT_LEVEL, CHILD_GROUP_ID, CHILD_LEVEL )
SELECT id, 0, id, 0
FROM GROUPS;

-- Progressively build lower levels
-- XXX Should really abort if nothing affected in a given pass
FOR closure_distance in 1..20 LOOP
  RAISE NOTICE 'Processing loop %', closure_distance;
  INSERT INTO GROUP_HIERARCHIES
  ( PARENT_GROUP_ID, PARENT_LEVEL, CHILD_GROUP_ID, CHILD_LEVEL )
  SELECT GH.PARENT_GROUP_ID, GH.PARENT_LEVEL, CHILD.ID, closure_distance
  FROM GROUP_HIERARCHIES GH, GROUPS CHILD
  WHERE GH.CHILD_GROUP_ID = CHILD.PARENT_ID
    AND GH.CHILD_LEVEL = closure_distance - 1;
END LOOP;


END;
$$ LANGUAGE plpgsql;