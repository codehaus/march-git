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
CREATE OR REPLACE FUNCTION sp_build_days(start DATE, finish DATE) RETURNS VOID AS $$
DECLARE
  current DATE;
BEGIN
  RAISE NOTICE 'Clearing days';
  TRUNCATE TABLE days;
  
  SELECT start INTO current;
  
  RAISE NOTICE 'Creating days';
  WHILE current < finish
  LOOP
      INSERT INTO days (dt) VALUES (current);
      SELECT current + 1 INTO current;
  END LOOP;
  
  RAISE NOTICE 'Setting up data';
  UPDATE days SET 
      is_weekday = CASE  
          WHEN DATE_PART('DOW', dt) IN (1,7)  
          THEN false 
          ELSE true END, 
      is_holiday = false, 
      Y = EXTRACT(YEAR FROM dt),
      Q = CASE 
          WHEN EXTRACT(MONTH FROM dt) <= 3 THEN 1 
          WHEN EXTRACT(MONTH FROM dt) <= 6 THEN 2 
          WHEN EXTRACT(MONTH FROM dt) <= 9 THEN 3 
          ELSE 4 END,  
        M = EXTRACT(MONTH FROM dt),  
      D = EXTRACT(DAY FROM dt),  
      DW = DATE_PART('DOW', dt),  
      monthname = TO_CHAR(dt, 'Month'),  
      dayname = TO_CHAR(dt, 'Day'),  
      W = EXTRACT(WEEK FROM dt);
      
  RETURN;
END;
$$ LANGUAGE plpgsql;

