require "rails_helper"

describe "a player" do
  describe "who has created a game" do
    before :each do
      @user_1 = create(:user)
      @user_2 = create(:user, auth_token: "kasvkb495489", email: "fakeymcfake@fake.com")

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}"}
      json_payload = {opponent_email: "#{@user_2.email}"}.to_json

      post "/api/v1/games", params: json_payload, headers: headers

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

    it "places a ship on their board" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}"}

      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(payload[:message]).to eq("Successfully placed ship with a size of 3. You have 1 ship(s) to place with a size of 2.")
      expect(@game.player_1_board.board.first.first["A1"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.first.second["A2"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.first.third["A3"].contents).to be_a(Ship)
    end

    it "places two ships on the board" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}"}

      post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}"}

      post "/api/v1/games/#{@game.id}/ships", params: @ship_2_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(payload[:message]).to eq("Successfully placed ship with a size of 2. You have 0 ship(s) to place.")
      expect(@game.player_1_board.board.fourth.first["D1"].contents).to be_a(Ship)
      expect(@game.player_1_board.board.fourth.second["D2"].contents).to be_a(Ship)
    end

    it "can not place a ship if it is not involved in the game" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "8y123998ashd"}

      expect{post "/api/v1/games/#{@game.id}/ships", params: @ship_1_payload, headers: headers}.to raise_error(UnauthorizedUser)
    end

  end
end
