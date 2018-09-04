class Api::V1::Games::ShipsController < ApiController
  before_action :authenticate_token

  def create
    @game = Game.find(params[:game_id])
    ship = Ship.new(params[:ship_size])
    board = authenticate_board(request.headers["X-API-KEY"], @game)

    ShipPlacer.new(
                     board: board,
                     ship: ship,
                     start_space: params[:start_space],
                     end_space: params[:end_space]
                  ).run
    @game.save

    message = ShipMessage.new(board, ship).validate
    render json: @game, message: message
  end
end
