class CreateStopWords < ActiveRecord::Migration
  def self.up
    create_table :stop_words do |t|
      t.string :word, :null => false
      t.timestamps  
    end
    
    add_index :stop_words, :word
    
    # insignificant numbers
    1.upto(100) { |i|
      StopWord.create(i)
    }

    # years
    2000.upto(2020) { |i|
      StopWord.create(i)
    }
    
    [ 'xircles.codehaus.org', '+44', 'list', 're' ].each { |word|
      StopWord.create(word)
    }
    
    DatabaseFunction.install_all
  end

  def self.down
    drop_table :stop_words
  end
end
