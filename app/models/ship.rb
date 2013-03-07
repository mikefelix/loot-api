class Ship < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
  belongs_to :target, polymorphic: true
  has_many :attackers, as: :target, class_name: 'Ship'

  attr_accessible :color, :state, :strength, :game

  def sail(target = nil)
      if color == MERCHANT
        raise "Merchants can only target the player." if !target.nil? and target != player
        self.target = player
      elsif color == ADMIRAL
        raise "The admiral can only target the player's own merchant." if target.nil? or !target.respond_to?(:color) or target.color != MERCHANT or target.player != player or target.state != PLAYED
        self.target = target
      else
        raise "Pirates can only target merchant ships." if target.nil? or !target.respond_to?(:color) or target.color != MERCHANT or target.state != PLAYED
        self.target = target
      end

      self.state = PLAYED
      save
  end

  def is_pirate?
    [BLUE, YELLOW, PURPLE, GREEN].include? color
  end

  def latest_attacker # player
    raise "Invalid call" if color != MERCHANT
    return player if attackers.empty?
    latest = attackers.inject {|a,b| if a.updated_at > b.updated_at then a else b end }
    latest.player
  end

  def winning_attacker # player
    raise "Invalid call" if color != MERCHANT
    return player if attackers.empty?
    scores = {}
    attackers.each do |a|
      scores[a.player] = 0 if scores[a.player].nil?
      scores[a.player] += a.strength
    end
    winner = nil
    scores.keys.each do |k|
      return nil if winner and scores[k] == scores[winner]
      winner = k if !winner or scores[k] > scores[winner]
    end
    winner
  end

  def to_s
    "#{strength}#{color}/#{id}"
  end
end

