class Api::V1::PlayersController < ApplicationController
  # Contains methods that will need to be authorized.
  before_filter :get_user

  def get_user
    session[:user_id] = 1 # TODO: remove
    raise "Access denied!" if !session[:user_id]
    @user = User.find session[:user_id]
  end

  def show
    player = Player.find params[:id]
    includes = {}
    if player.user == @user
      includes[:hand] = {
          only: [:strength, :id],
          methods: :color_str
      }
    end
    render json: player.as_json({ include: includes })
  end
end
