class Rating < ActiveRecord::Base
  MAX = 5
  
  def html_id
    return Rating.html_id_for_target(self)
  end

  def self.html_id_for_target(target)
    "rating-#{rating.id}"
  end

end
