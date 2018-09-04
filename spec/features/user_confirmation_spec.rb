require "rails_helper"

describe "an unregistered user" do
  it "goes to confirmation link" do
    user = create(:user, status: "inactive")
    visit confirmation_url(auth_token: user.auth_token)

    expect(current_path).to eq(confirmed_path)
    user.reload

    expect(page).to have_content("Thank you! Your account is now activated.")

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit dashboard_path

    expect(user.reload.status).to eq("active")
  end
end
