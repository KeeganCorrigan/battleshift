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
    expect(game.current_turn).to eq("player_1")
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
