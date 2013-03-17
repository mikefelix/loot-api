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
    users = params[:users].map {|id| User.find id }
    @game = Game.create_game name: params[:name], users: users
    render json: @game
  end
end
