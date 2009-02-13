
class ActiveRecord::Migration
  def self.fk(table,column)
    execute "ALTER TABLE #{table} ADD CONSTRAINT fk_#{table}_#{Inflector.pluralize(column.to_s)} FOREIGN KEY ( #{column}_id ) REFERENCES #{Inflector.pluralize(column.to_s)}( id )"
  end

  def self.drop_fk(table,column)
    execute "ALTER TABLE #{table} DROP CONSTRAINT fk_#{table}_#{Inflector.pluralize(column.to_s)}"
  end

  def self.fk_exactly(table,column,fk_table)
    execute "ALTER TABLE #{table} ADD CONSTRAINT fk_#{table}_#{column} FOREIGN KEY ( #{column} ) REFERENCES #{fk_table}( id )"
  end

  def self.drop_fk_exactly(table,column)
    execute "ALTER TABLE #{table} DROP CONSTRAINT fk_#{table}_#{column}"
  end
end
