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

-- When a rating changes; updates the associated message totals
CREATE OR REPLACE FUNCTION trg_rating_message() RETURNS trigger AS $$
DECLARE
  total_delta INTEGER;
  count_delta INTEGER;
  message_id INTEGER;
BEGIN
  total_delta := 0;
  count_delta := 0;

  IF TG_OP = 'UPDATE' THEN
    IF old.message_id <> new.message_id THEN
      RAISE EXCEPTION 'You can not move a rating from one message to another';
    END IF;
  END IF;
  
  -- Phase 1; subtract the current values
  IF (TG_OP = 'DELETE') OR (TG_OP = 'UPDATE') THEN
    message_id := old.message_id;
    total_delta := total_delta - COALESCE(old.value, 0);
    count_delta := count_delta - 1;
  END IF;
  
  -- Phase 2; add the new values
  IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
    message_id := new.message_id;
    total_delta := total_delta + COALESCE(new.value, 0);
    count_delta := count_delta + 1;
  END IF;
  
  -- For big instances, you may not have zeroed the messages initially
  UPDATE messages m
  SET rating_total = COALESCE(rating_total, 0) + total_delta,
      rating_count = COALESCE(rating_count, 0) + count_delta
  WHERE id = message_id;
  
  IF TG_OP = 'DELETE' THEN
    RETURN old;
  ELSE
    RETURN new;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Piss weak test plan
-- DELETE FROM RATINGS; UPDATE MESSAGES SET RATING_TOTAL = 0, RATING_COUNT = 0;
-- INSERT INTO RATINGS VALUES (1, 1, 1, 1);
-- INSERT INTO RATINGS VALUES (2, 1, 1, 1);
-- INSERT INTO RATINGS VALUES (3, 1, 1, 1);
-- SELECT * FROM MESSAGES WHERE ID IN (1,2);
-- UPDATE RATINGS SET VALUE = 2;
-- SELECT * FROM MESSAGES WHERE ID IN (1,2);
-- DELETE FROM RATINGS; 