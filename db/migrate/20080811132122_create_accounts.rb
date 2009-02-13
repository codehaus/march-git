class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :identifier, :null => false
      t.string :nickname, :null => true
      t.string :fullname, :null => true
      t.timestamps
    end
    
    create_table :favorites do |t|
      t.column :user_id,        :integer, :null=>false, :deferrable => true
      t.column :target_type, :string,  :null=>false, :limit=>128
      t.column :target_id,   :integer, :null=>false, :references => nil
      t.column :created_at, :timestamptz, :null => true
      t.column :updated_at, :timestamptz, :null => true
    end
  end

  def self.down
    drop_table :favorites
    drop_table :users
  end
end
