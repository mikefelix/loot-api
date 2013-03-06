class Api::V1::TurnsController < ApplicationController
  # GET /turns.json
  def index
    @turns = Turn.all
    render json: @turns
  end

  # GET /turn.json
  def show
    @turn = Turn.find params[:id]
    render json: @turn
  end
end
