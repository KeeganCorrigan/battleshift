require 'rails_helper'

describe "Api::V1::Shots" do
  context "POST /api/v1/games/:id/shots" do
    before :each do
      @user_1 = create(:user)
      @user_2 = create(:user, auth_token: "kasvkb495489", email: "fakeymcfake@fake.com")

      p1_board = Board.new(4)
      p2_board = Board.new(4)

      sm_ship = Ship.new(2)
      md_ship = Ship.new(3)

      sm2_ship = Ship.new(2)
      md2_ship = Ship.new(3)

      ShipPlacer.new(
                      board: p1_board,
                      ship: sm_ship,
                      start_space: "A1",
                      end_space: "A2"
                    ).run

      ShipPlacer.new(
                      board: p1_board,
                      ship: md_ship,
                      start_space: "B1",
                      end_space: "D1"
                    ).run

      ShipPlacer.new(
                      board: p2_board,
                      ship: sm2_ship,
                      start_space: "A1",
                      end_space: "A2"
                    ).run

      ShipPlacer.new(
                      board: p2_board,
                      ship: md2_ship,
                      start_space: "B1",
                      end_space: "D1"
                    ).run

      @game = Game.create!(
                        player_1_board: p1_board,
                        player_2_board: p2_board,
                        winner: nil,
                        player_1_turns: 0,
                        player_2_turns: 0,
                        player_1_auth_token: @user_1.auth_token,
                        player_2_auth_token: @user_2.auth_token,
                        current_turn: "player_1",
                        player_1: @user_1,
                        player_2: @user_2
                      )

    end

    it "player_1 can fire a shot" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }

      targeted_space = "A1"

      json_payload = {target: targeted_space}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(@game.player_2_board.board.first.first[targeted_space].status).to eq("Hit")
      expect(response).to be_success
      expect(payload[:message]).to eq("Your shot resulted in a Hit.")
    end

    it "can not fire on an invalid coordinate" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A5"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers
      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(response.status).to eq(400)
      expect(payload[:message]).to eq("Invalid coordinates.")
    end

    it "fires on an already fired upon coordinate" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A1"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }
      json_payload = {target: "A1"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A1"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers
      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(response.status).to eq(200)
      expect(payload[:message]).to eq("Your shot resulted in a Miss.")
    end

    it "player 1 can not fire 2 shots in a row" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }

      json_payload = {target: "A1"}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      targeted_space = "A2"

      json_payload = {target: targeted_space}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      expect(expect(@game.player_2_board.board.first.second[targeted_space].status).to eq("Not Attacked"))
      expect(payload[:message]).to eq("Invalid move. It's your opponent's turn")
    end

    it "player 1 can fire and then player 2 can fire" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }

      json_payload = {target: "A1"}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }

      targeted_space = "A3"

      json_payload = {target: "A3"}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(expect(@game.player_1_board.board.first.third[targeted_space].status).to eq("Miss"))
      expect(payload[:message]).to eq("Your shot resulted in a Miss.")
    end

    it "player 2 can not fire first" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }

      json_payload = {target: "A1"}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      targeted_space = "A1"

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(expect(@game.player_1_board.board.first.first[targeted_space].status).to eq("Not Attacked"))
      expect(payload[:message]).to eq("Invalid move. It's your opponent's turn")
    end

    it "sends message about invalid coordinates and returns 400 status" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }

      targeted_space = "D5"
      json_payload = {target: targeted_space}.to_json

      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(response).to have_http_status(400)
      expect(payload[:message]).to eq("Invalid coordinates.")
    end

    it "displays a message when a battleship is sunk" do
      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A1"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }
      json_payload = {target: "A3"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers
      payload = JSON.parse(response.body, symbolize_names: true)

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A2"}.to_json
      post "/api/v1/games/#{@game.id}/shots", params: json_payload, headers: headers
      payload = JSON.parse(response.body, symbolize_names: true)

      @game.reload

      expect(payload[:winner]).to eq(nil)
      expect(response).to have_http_status(200)
      expect(payload[:message]).to eq("Your shot resulted in a Hit. Battleship sunk.")
    end

    it "displays game over message when all ships are sunk" do
      p1_board = Board.new(4)
      p2_board = Board.new(4)

      sm_ship = Ship.new(2)
      sm2_ship = Ship.new(2)

      ShipPlacer.new(
                      board: p2_board,
                      ship: sm_ship,
                      start_space: "A1",
                      end_space: "A2"
                    ).run

      ShipPlacer.new(
                      board: p1_board,
                      ship: sm2_ship,
                      start_space: "A1",
                      end_space: "A2"
                    ).run

      game = Game.create!(
                        player_1_board: p1_board,
                        player_2_board: p2_board,
                        winner: nil,
                        player_1_turns: 0,
                        player_2_turns: 0,
                        player_1_auth_token: @user_1.auth_token,
                        player_2_auth_token: @user_2.auth_token,
                        current_turn: "player_1",
                        player_1: @user_1,
                        player_2: @user_2
                      )

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A1"}.to_json
      post "/api/v1/games/#{game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }
      json_payload = {target: "A3"}.to_json
      post "/api/v1/games/#{game.id}/shots", params: json_payload, headers: headers

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_1.auth_token}" }
      json_payload = {target: "A2"}.to_json
      post "/api/v1/games/#{game.id}/shots", params: json_payload, headers: headers

      game.reload

      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(200)
      expect(payload[:winner]).to eq("#{@user_1.email}")
      expect(payload[:message]).to eq("Your shot resulted in a Hit. Battleship sunk. Game over.")

      headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{@user_2.auth_token}" }
      json_payload = {target: "A4"}.to_json
      post "/api/v1/games/#{game.id}/shots", params: json_payload, headers: headers

      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(400)
      expect(payload[:message]).to include("Invalid move. Game over.")
    end
  end
end
