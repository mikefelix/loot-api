class Turn < ActiveRecord::Base
  belongs_to :player
  belongs_to :ship
  attr_accessible :num, :target
end
