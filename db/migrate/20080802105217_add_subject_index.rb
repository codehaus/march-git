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
