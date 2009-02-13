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
CREATE OR REPLACE FUNCTION sp_contents_data_trigger() RETURNS trigger AS $$
DECLARE
  data_text TEXT;
  indexed_level INTEGER;
  indexed_length INTEGER;
BEGIN
  indexed_level := 4; -- Controls what round of indexing we're doing (useful for incremental changes to the index)
  indexed_length := 32768; -- Only index the first portion of a message
  
  -- Are we attempting to index non text/plain data
  -- Rationale: Non text would need cleaning (e.g. HTML / ZIP attachments etc)
  IF SUBSTRING(new.content_type, 1, 10) <> 'text/plain' AND SUBSTRING(new.content_type, 1, 9) <> 'text/html' THEN
    new.data_tsv := NULL;
    RETURN new;
  END IF;
  
  -- Is our index is up-to-date?
  IF new.data_tsv IS NOT NULL AND new.data_indexed >= indexed_level THEN
    RETURN new;
  END IF;
  
  data_text := encode(new.data,'escape');
  -- Limit index to first "indexed_length" portion
  IF LENGTH(data_text) > indexed_length THEN
    data_text := SUBSTRING(data_text, 1, indexed_length);
  END IF;
  
  SET MAINTENANCE_WORK_MEM = '1GB';
  new.data_tsv := strip(to_tsvector('march_config', data_text));
  new.data_indexed := indexed_level;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql;