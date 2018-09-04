require "rails_helper"
require "spec_helper"

describe Ship, type: :model do
  it "has attributes" do
    ship = Ship.new(2)
    length_spy = Spy.on(ship, :length)
    damage_spy = Spy.on(ship, :damage)
    ship.length
    ship.damage

    assert length_spy.has_been_called?
    assert_equal 1, length_spy.calls.count

    assert damage_spy.has_been_called?
    assert_equal 1, damage_spy.calls.count
  end

  context "instance methods" do
    describe "#take_damage" do
      let(:ship) { Ship.new(2)}

      it "increments damage counter" do
        ship.take_damage

        expect(ship.damage).to eq(1)
      end
    end
    describe "#is_sunk?" do
      let(:ship) { Ship.new(2)}

      it "returns true if damage is equivalent to length" do
        ship.take_damage
        expect(ship.is_sunk?).to eq(false)

        ship.take_damage
        expect(ship.is_sunk?).to eq(true)
      end
    end
  end
end
