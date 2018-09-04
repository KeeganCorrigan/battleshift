class ApiController < ActionController::API
  def authenticate_board(auth_token, game)
    if auth_token == game.player_1_auth_token
      game.player_1_board
    elsif auth_token == game.player_2_auth_token
      game.player_2_board
    end
  end

  def set_opponent_board(auth_token, game)
    if auth_token == game.player_1_auth_token
      game.player_2_board
    elsif auth_token == game.player_2_auth_token
      game.player_1_board
    end
  end

  def authenticate_token
    api_key = request.headers['X-API-KEY']
    user = User.where(auth_token: api_key).first if api_key

    unless user
      render json: { message: "Unauthorized" }, status: 401
      return false
    end
  end

  def authenticate_email
    email = params["opponent-email"] || params[:opponent_email]
    user = User.where(email: email).first if email

    unless user
      render json: { message: "Invalid email." }, status: 400
      return false
    end
  end

  def game_over
    game = Game.find(params[:game_id])
    if game.winner
      render json: @game, message: "Invalid move. Game over.", status: 400
    end
  end
end
