class Api::V1::GamesController < ApiController
  before_action :authenticate_token, :authenticate_email, :set_players

  def create
    render json: @game if create_game(@player_1, @player_2).save!
  end

  private

  def set_players
    @player_1 = User.find_by(auth_token: request.headers["X-API-KEY"])
    @player_2 = User.find_by(email: params["opponent-email"]) || User.find_by(email: params[:opponent_email])
    validate_status(@player_1, @player_2)
  end

  def validate_status(player_1, player_2)
    unless [player_1, player_2].all? { |player| player.status == "active" }
      render json: { message: "Unauthorized" }, status: 401
    end
  end

  def create_game(player_1, player_2)
    @game = Game.new({
      player_1_board: Board.new(4),
      player_2_board: Board.new(4),
      player_1_turns: 0,
      player_2_turns: 0,
      player_1_auth_token: player_1.auth_token,
      player_2_auth_token: player_2.auth_token,
      current_turn: "player_1",
      player_1: player_1,
      player_2: player_2
    })
  end
end
