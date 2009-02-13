#Ideally the stop word is added to the postgres dictionary.
#However reindexing the entire contents table is slooooow

class StopWord < ActiveRecord::Base
  def self.create(word)
    return if not word
    word = word.to_s.strip.downcase
    return if word.blank?
    
    w = StopWord.find_or_create_by_word(word)
  end
    
end
