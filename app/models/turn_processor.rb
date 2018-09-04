class TurnProcessor
  def initialize(game, target, board, user)
    @user     = user
    @game     = game
    @target   = target
    @messages = []
    @board    = board
  end

  def run!
    begin
      attack_opponent
      game.save!
    end
  end

  def message
    @messages.join(" ")
  end

  private

  attr_reader :game, :target

  def attack_opponent
    result = Shooter.new(board: @board, target: target).fire!
    update_message(result)
    update_winner(result)
  end

  def update_message(result)
    @messages << "Your shot resulted in a #{result[:ship_status]}."
    @messages << "Battleship sunk." if result[:sunk] == true
    @messages << "Game over." if result[:game_over] == true
  end

  def update_winner(result)
    @game.winner = @user.email if result[:game_over] == true
  end
end
