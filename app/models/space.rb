class Space
  attr_reader :coordinates, :status, :contents

  def initialize(coordinates)
    @coordinates = coordinates
    @contents    = nil
    @status      = "Not Attacked"
  end

  def change_status
    if contents && not_attacked?
      hit
    else
      miss
    end
  end

  def occupy!(ship)
    @contents = ship
  end

  def occupied?
    !!@contents
  end

  private

  def hit
    contents.take_damage
    @status = "Hit"
  end

  def miss
    @status = "Miss"
  end

  def not_attacked?
    status == "Not Attacked"
  end
end
