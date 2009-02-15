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

class AddSubjectIndex < ActiveRecord::Migration
  def self.up
    add_column :messages, :subject_tsv, :tsvector

    DatabaseFunction.install('trg_message_subject')

    sql = <<EOF
        CREATE TRIGGER message_subject_tsv_update BEFORE INSERT OR UPDATE
        ON messages FOR EACH ROW EXECUTE PROCEDURE
        trg_message_subject();
EOF
    Message.connection.execute(sql)


    sql = <<EOF
    SET MAINTENANCE_WORK_MEM = '1GB';
    CREATE INDEX idx_message_subject_tsv_gin ON messages USING gin(subject_tsv);
EOF
    Message.connection.execute(sql)
    
  end

  def self.down
    remove_column :messages, :subject_tsv
  end
end
