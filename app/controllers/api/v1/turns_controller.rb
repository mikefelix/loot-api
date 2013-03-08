class Api::V1::TurnsController < ApplicationController
  # GET /turns.json
  def index
    turns = Turn.all
    render json: turns
  end

  # GET /turn.json
  def show
    turn = Turn.find params[:id]
    render json: turn
  end

  #POST /turn.json
  def create
    player = Player.find params[:id]
    ship = if params[:ship_id] then Ship.find params[:ship_id] else nil end
    target = nil
    if ship and params[:target_id]
      if ship.is_merchant?
        target = Player.find params[:target_id]
      else
        target = Ship.find params[:target_id]
      end

    end

    turn = player.take_turn ship, target
    render json: turn
  end
end
