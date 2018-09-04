require "rails_helper"

describe "a player" do
  describe "who has created a game" do
    before :each do
      @user_1 = create(:user)
      @user_2 = create(:user, auth_token: "kasvkb495489", email: "fakeymcfake@fake.com")

      @player_1_headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      @player_2_headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }

      json_payload = {opponent_email: "#{@user_2.email}"}.to_json

      post "/api/v1/games", params: json_payload, headers: @player_1_headers

      @game = Game.last

      @ship_1_payload = {
                          ship_size: 3,
                          start_space: "A1",
                          end_space: "A3"
                        }.to_json

      @ship_2_payload = {
                          ship_size: 2,
                          start_space: "D1",
                          end_space: "D2"
                        }.to_json
    end

    it "player 1 places a ship on their board" do
      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: @player_1_headers
      payload = JSON.parse(response.body, symbolize_names: true)
      @game.reload

      expect(payload[:message]).to eq("Successfully placed ship with a size of 3. You have 1 ship(s) to place with a size of 2.")
      expect(@game.player_1_board.board.first.first["A1"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.first.second["A2"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.first.third["A3"].contents).to be_a(Ship)
    end

    it "player 1 places two ships on the board" do
      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: @player_1_headers
      post "/api/v1/games/#{@game.id}/ships", params: @ship_2_payload, headers: @player_1_headers
      payload = JSON.parse(response.body, symbolize_names: true)
      @game.reload

      expect(payload[:message]).to eq("Successfully placed ship with a size of 2. You have 0 ship(s) to place.")
      expect(@game.player_1_board.board.fourth.first["D1"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.fourth.second["D2"].contents).to be_a(Ship)
    end

    it "raises error when placing a ship on a preexisting ship" do
      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: @player_1_headers
      @game.reload

      ship_2_payload =  {
                          ship_size: 2,
                          start_space: "A1",
                          end_space: "A2"
                        }.to_json

      expect{ post "/api/v1/games/#{@game.id}/ships", params: ship_2_payload, headers: @player_1_headers }.to raise_error(InvalidShipPlacement)
    end

    it "raises error when ship start and end points are incorrect" do
      ship_1_payload =  {
                          ship_size: 2,
                          start_space: "A1",
                          end_space: "A3"
                        }.to_json

      expect{ post "/api/v1/games/#{@game.id}/ships", params: ship_1_payload, headers: @player_1_headers }.to raise_error(InvalidShipPlacement)
    end

    it "player 2 places a ship on board" do
      post "/api/v1/games/#{@game.id}/ships", params: @ship_2_payload, headers: @player_2_headers
      payload = JSON.parse(response.body, symbolize_names: true)
      @game.reload

      expect(payload[:message]).to eq("Successfully placed ship with a size of 2. You have 1 ship(s) to place with a size of 3.")
      expect(@game.player_2_board.board.fourth.first["D1"].contents).to be_a(Ship)
      expect(@game.player_2_board.board.fourth.second["D2"].contents).to be_a(Ship)
    end

    it "can not place a ship if it is not involved in the game" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#8y123998ashd"}
      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: headers
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(401)
      expect(payload[:message]).to eq("Unauthorized")
    end

    it "can not place more than 2 ships" do
      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: @player_1_headers
      post "/api/v1/games/#{@game.id}/ships", params: @ship_2_payload, headers: @player_1_headers

      ship_3_payload = {
                          ship_size: 3,
                          start_space: "C1",
                          end_space: "C3"
                        }.to_json

      @game.reload

      expect{ post "/api/v1/games/#{@game.id}/ships", params: ship_3_payload, headers: @player_1_headers }.to raise_error(InvalidShipPlacement)
    end
  end
end
