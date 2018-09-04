require 'rails_helper'

describe 'post api/v1/games' do
  it 'can create a new game' do
    user_1 = create(:user)
    user_2 = create(:user, auth_token: "kasvkb495489", email: "fakeymcfake@fake.com")
    headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{user_1.auth_token}"}
    json_payload = {opponent_email: "#{user_2.email}"}.to_json
    post "/api/v1/games", params: json_payload, headers: headers

    game = Game.last

    expect(Game.count).to eq(1)
    expect(game.player_1_auth_token).to eq(user_1.auth_token)
    expect(game.player_2_auth_token).to eq(user_2.auth_token)
  end

  it "can not create a game with invalid email" do
    user_1 = create(:user)
    headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "#{user_1.auth_token}"}
    json_payload = {opponent_email: "0js09j0jads"}.to_json
    post "/api/v1/games", params: json_payload, headers: headers

    payload = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(400)
    expect(payload[:message]).to eq("Invalid email.")
    expect(Game.count).to eq(0)
  end

  it "can not create a game with invalid token" do
    user_1 = create(:user)
    headers = { "CONTENT_TYPE" => "application/json", "X-API-KEY" => "0u9jdasiojoid"}
    json_payload = {opponent_email: "0js09j0jads"}.to_json
    post "/api/v1/games", params: json_payload, headers: headers

    payload = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(401)
    expect(payload[:message]).to eq("Unauthorized")
    expect(Game.count).to eq(0)
  end
end
