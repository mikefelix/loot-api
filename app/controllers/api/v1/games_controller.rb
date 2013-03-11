class Api::V1::GamesController < ApplicationController

  # GET /games.json
  def index
    @games = Game.all
    render json: @games
  end

  # GET /game.json
  def show
    @game = Game.find params[:id]
    render json: @game
  end

  # POST /game.json
  def create
    @game = Game.create_game params
    render json: @game
  end
end
