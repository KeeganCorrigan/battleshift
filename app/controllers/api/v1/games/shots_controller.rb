class Api::V1::Games::ShotsController < ApiController
  before_action :authenticate_token, :set_game, :validate_coordinates, :set_user, :game_over
  
  def create
    auth_token = response.request.env["HTTP_X_API_KEY"]
    board = set_opponent_board(request.headers["X-API-KEY"], @game)

    if @game.validate_turn(auth_token) == true
      turn_processor = TurnProcessor.new(@game, params[:shot][:target], board, @current_user)
      turn_processor.run!
      @game.change_turns
      render json: @game, message: turn_processor.message
    else
      render json: @game, message: @game.validate_turn(auth_token), status: 400
    end
  end

  private

  def set_user
    @current_user = User.find_by(auth_token: response.request.env["HTTP_X_API_KEY"])
  end

  def set_game
    @game = Game.find(params[:game_id])
  end

  def validate_coordinates
    render json: @game, message: "Invalid coordinates.", status: 400 unless @game.player_1_board.space_names.include?(params[:target])
  end
end
