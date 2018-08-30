class Api::V1::Games::ShipsController < ApiController

# TODO create authentication method for create function

  def create
    # TODO: remove class method, find by user auth_token?
    @game = Game.find(params[:game_id])

    ship = Ship.new(params[:ship_size])

    board = authenticate_board(request.headers["X-API-KEY"])

    if board
      ShipPlacer.new(
                       board: board,
                       ship: ship,
                       start_space: params[:start_space],
                       end_space: params[:end_space]
                    ).run
      @game.save

    # board.board.map do |row|
    #   row.map do |space|
    #     binding.pry
    #   end
    # end

      "Successfully placed ship with a size of #{ship.length}. You have 1 ship(s) to place with a size of 2."

      message = ShipMessage.new(board, ship).validate

      render json: @game, message: message
    else
      raise UnauthorizedUser.new
    end

  end

  private

  def authenticate_board(auth_token)
    if auth_token == @game.player_1_auth_token
      @game.player_1_board
    elsif auth_token == @game.player_2_auth_token
      @game.player_2_board
    end
  end
end


# TODO: move this from controller level
class UnauthorizedUser < StandardError
  def initialize(msg = "You are not authorized to play this game")
    super
  end
end
