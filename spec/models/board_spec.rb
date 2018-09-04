require "rails_helper"

describe Board, type: :model do
  describe "instance methods" do
    before :each do
      sm_ship = Ship.new(2)
      md_ship = Ship.new(3)
      @board = Board.new(4)

      ShipPlacer.new(
        board: @board,
        ship: sm_ship,
        start_space: "A1",
        end_space: "A2"
      ).run

      ShipPlacer.new(
        board: @board,
        ship: md_ship,
        start_space: "C1",
        end_space: "C3"
      ).run
    end

    describe "#ships" do
      it "returns an array of unique ship objects on board" do
        expect(@board.ships.length).to eq(2)
        expect(@board.ships.first).to be_a(Ship)
      end
    end
  end
end
