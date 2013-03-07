class Turn < ActiveRecord::Base
  belongs_to :player
  belongs_to :ship
  belongs_to :target, polymorphic: true
  attr_accessible :num, :player, :ship, :target
end
