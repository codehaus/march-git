################################################################################
#  Copyright 2006-2009 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

#SELECT id FROM contents WHERE tsv @@ to_tsquery('monkey') ORDER BY id DESC LIMIT 10;

class AddTsearch < ActiveRecord::Migration
  def self.up
    #Content.connection.execute("CREATE INDEX tsv_index_gin ON contents USING gin(to_tsvector('english', encode(data, 'escape')))")

    add_column :contents, :data_tsv, :tsvector
    #GIN is a much better index; but it is very slow to create / update
    #Content.connection.execute("CREATE INDEX idx_data_tsv_gin ON contents USING gin(data_tsv)")
    #GIST is faster to create / update; but marginally slower to query (read the PostgreSQL docs)
    # MAINTENANCE_WORK_MEM only impacts GIN index build times
    sql = <<EOF
      SET MAINTENANCE_WORK_MEM = '1GB';
      CREATE INDEX idx_data_tsv_gin ON contents USING gin(data_tsv);
      --CREATE INDEX idx_data_tsv_gist ON contents USING gist(data_tsv);
EOF
    Content.connection.execute(sql)
    
    sql = <<EOF
    CREATE OR REPLACE FUNCTION sp_contents_data_trigger() RETURNS trigger AS $$
    BEGIN
    END;
    $$ LANGUAGE plpgsql;
    CREATE TRIGGER contents_data_tsv_update BEFORE INSERT OR UPDATE
    ON contents FOR EACH ROW EXECUTE PROCEDURE
    sp_contents_data_trigger();
EOF
    drop_trigger('contents', 'contents_data_tsv_update')
    Content.connection.execute(sql)
  end

  notes = <<EOF
  SELECT m.subject, m.message_id822
  FROM contents c, parts p, messages m
  WHERE p.content_id = c.id 
  and p.message_id = m.id
  and data_tsv @@ to_tsquery('simple', 'camp');


  CREATE TEXT SEARCH DICTIONARY english (
           TEMPLATE = ispell,
           DictFile = 'ispell_sample', --'english-utf8.dict',
           AffFile =  'ispell_sample', --'english-utf8.aff',
           StopWords = english
  );

  CREATE TEXT SEARCH CONFIGURATION pg_catalog.english (
      PARSER = default
  );
  
  CREATE TEXT SEARCH DICTIONARY march_dict (
      TEMPLATE = simple,
      StopWords = march
      );

  CREATE TEXT SEARCH CONFIGURATION march_config ( COPY = pg_catalog.simple );

  ALTER TEXT SEARCH CONFIGURATION march_config
      ALTER MAPPING FOR asciiword, 
                        asciihword, 
                        hword_asciipart,
                        word, 
                        hword, 
                        hword_part
      WITH march_dict;
 
  UPDATE contents SET tsv = to_tsvector(encode(data, 'escape'))
  UPDATE contents SET tsv = to_tsvector(convert_from('text_in_utf8', 'UTF8'));
  
  convert_from('text_in_utf8', 'UTF8')
EOF


  def self.down
    remove_column :contents, :data_tsv
    drop_trigger('contents', 'tsvectorupdate')
    drop_index('tsv_index_gin')
  end
  
  def self.drop_function(function)
    Content.connection.execute("DROP FUNCTION #{function}")
  end
  
  def self.drop_trigger(table, trigger)
    Content.connection.execute("DROP TRIGGER IF EXISTS #{trigger} ON #{table}")
  end
  
  def self.drop_index(index)
    Content.connection.execute("DROP INDEX IF EXISTS #{index}")
  end
  
end
