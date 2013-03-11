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
    puts "This user is #{@user.name}"
    puts "This user id is #{player.user_id}"
    puts "Player's user is #{player.user.nil? ? 'nil' : player.user.name}"
    if player.user != @user
      render text: "Access denied!"
    else
      render json: player.to_json(include: :hand)
    end
  end
end
