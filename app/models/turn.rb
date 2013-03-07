class Turn < ActiveRecord::Base
  belongs_to :player
  belongs_to :ship
  belongs_to :target, polymorphic: true
  attr_accessible :num, :player, :ship, :target, :action

  def captures
    Ship.find_all_by_won_in num
  end
end
