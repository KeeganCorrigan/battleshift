require "rails_helper"

describe ShipMessage, type: :model do
  describe "instance methods" do
    describe "#validate" do
      it "detects presence of 2 ship" do
        sm_ship = Ship.new(2)
        board = Board.new(4)

        ShipPlacer.new(
          board: board,
          ship: sm_ship,
          start_space: "A1",
          end_space: "A2"
        ).run

        ship_message = ShipMessage.new(board, sm_ship)

        expect(ship_message.validate).to eq("Successfully placed ship with a size of 2. You have 1 ship(s) to place with a size of 3.")
      end
    end

    describe "#validate" do
      before :each do
        @board = Board.new(4)
        @md_ship = Ship.new(3)
      end

      it "detects presence of size 3 ship" do

        ShipPlacer.new(
          board: @board,
          ship: @md_ship,
          start_space: "A1",
          end_space: "A3"
        ).run

        ship_message = ShipMessage.new(@board, @md_ship)

        expect(ship_message.validate).to eq("Successfully placed ship with a size of 3. You have 1 ship(s) to place with a size of 2.")
      end

      it "returns correct message if all ships are placed" do
        sm_ship = Ship.new(2)

        ShipPlacer.new(
          board: @board,
          ship: @md_ship,
          start_space: "A1",
          end_space: "A3"
        ).run

        ShipPlacer.new(
          board: @board,
          ship: sm_ship,
          start_space: "D1",
          end_space: "D2"
        ).run

        ship_message = ShipMessage.new(@board, sm_ship)

        expect(ship_message.validate).to eq("Successfully placed ship with a size of 2. You have 0 ship(s) to place.")
      end
    end
  end
end
