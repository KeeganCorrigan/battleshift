require 'rails_helper'

describe Game, type: :model do
  it "has attributes" do
    game = create(:game, player_1: create(:user, status: "active"), player_2: create(:user, auth_token: "andrew", email: "califormula@gmail.com", status: "active"))

    expect(game.player_1_board).to be_a(Board)
    expect(game.player_2_board).to be_a(Board)
    expect(game.player_1_turns).to eq(0)
    expect(game.player_2_turns).to eq(0)
    expect(game.player_1_auth_token).to eq("ouhasdio")
    expect(game.player_2_auth_token).to eq("98has98hasd")
    allow_any_instance_of(Game).to receive(:current_turn).and_return("player_1")
    allow_any_instance_of(Game).to receive(:player_1).and_return(User.first)
    allow_any_instance_of(Game).to receive(:player_2).and_return(User.last)

    expect(game.player_1).to eq(User.first)
    expect(game.player_2).to eq(User.last)
  end

  describe "Relationships" do
    it { should belong_to(:player_1) }
    it { should belong_to(:player_2) }
  end

  describe "instance methods" do
    describe "#change_turns" do
      it "can switch turn from player_1 to player_2" do
        game = create(:game, player_1: create(:user, status: "active"), player_2: create(:user, auth_token: "andrew", email: "califormula@gmail.com", status: "active"))

        game.change_turns

        expect(game.current_turn).to eq("player_2")
      end
    end

    describe "#validate_turn" do
      it "validates current_turn" do
        game = create(:game, player_1: create(:user, status: "active"), player_2: create(:user, auth_token: "andrew", email: "califormula@gmail.com", status: "active"))
        auth_token = "ouhasdio"

        expect(game.validate_turn(auth_token)).to eq(true)

        game.change_turns

        expect(game.validate_turn(auth_token)).to eq("Invalid move. It's your opponent's turn")
      end
    end
  end
end
