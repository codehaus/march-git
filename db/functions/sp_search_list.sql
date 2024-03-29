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
CREATE OR REPLACE FUNCTION sp_search_list(p_list_id INTEGER, p_query TSQUERY) RETURNS SETOF messages AS $$
BEGIN
  SET STATEMENT_TIMEOUT TO 30000;
  RETURN QUERY SELECT m.*
    FROM messages m
    WHERE m.id IN (
      SELECT message_id FROM (
        SELECT
          c.message_id
        FROM contents c
        WHERE data_tsv @@ p_query
          AND list_id = p_list_id
        LIMIT 25
      ) PARTA
        
      UNION ALL
      
      SELECT id FROM (
        SELECT id
        FROM messages m
        WHERE subject_tsv @@ p_query
          AND list_id = p_list_id
        LIMIT 25
      ) PARTB
    )
    ORDER BY SENT_AT DESC
    LIMIT 25;
    SET STATEMENT_TIMEOUT TO DEFAULT;
END;
$$ LANGUAGE plpgsql;