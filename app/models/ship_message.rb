class ShipMessage
  def initialize(board, ship)
    @board = board.board
    @ship_length = ship.length
    @remainder = 5
  end

  def validate
    ship_length_string + ships_left_string
  end

  private

  def ships_left_string
    if ship_count < @remainder
      "You have #{ships_left} ship(s) to place with a size of #{@remainder - ship_count}."
    elsif ship_count == @remainder
      "You have #{ships_left} ship(s) to place."
    end
  end

  def ship_length_string
    "Successfully placed ship with a size of #{@ship_length}. "
  end

  def ships_left
    if ship_count < @remainder
      return 1
    elsif ship_count == @remainder
      return 0
    end
  end

  def ship_count
    @board.inject(0) do |sum, row|
      row.each do |space|
        (sum += 1) if space.values.first.contents
      end
      sum
    end
  end
end
