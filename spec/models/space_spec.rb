require "rails_helper"

describe Space, type: :model do
  context "attributes" do
    it "has attributes" do
      space_1 = Space.new("A1")
      ship_1 = Ship.new(2)

      allow_any_instance_of(Space).to receive(:contents).and_return(ship_1)
      allow_any_instance_of(Space).to receive(:status).and_return("Not Attacked")

      expect(space_1.coordinates).to eq("A1")
      expect(space_1.contents).to be_a(Ship)
      expect(space_1.status).to eq("Not Attacked")
    end
  end

  context "instance methods" do
    describe "#change_status" do
      it "updates status based on content" do
        space_1 = Space.new("A1")
        ship_1 = Ship.new(2)
        expect(space_1.change_status).to eq("Miss")

        space_1 = Space.new("A1")
        allow_any_instance_of(Space).to receive(:contents).and_return(ship_1)
        allow_any_instance_of(Ship).to receive(:take_damage).and_return(1)
        expect(space_1.change_status).to eq("Hit")
      end
    end

    describe "#occupy!" do
      it "adds ship to contents" do
        space_1 = Space.new("A1")
        ship_1 = Ship.new(2)

        space_1.occupy!(ship_1)

        expect(space_1.contents).to eq(ship_1)
      end
    end
  end
end
