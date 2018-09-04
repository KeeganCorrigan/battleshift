require "rails_helper"

describe "a visitor" do
  context "visits /" do
    it "clicks on register" do
      visit root_path

      expect(page).to have_content("Register")

      click_on "Register"

      expect(current_path).to eq(register_path)
    end

    it "fills in email address, name, password, and password confirmation and clicks submit" do
      visit register_path

      email = "fake@fake.com"
      name = "Fakety fake fake"
      password = "1234"

      fill_in :user_email, with: email
      fill_in :user_name, with: name
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: password

      click_on "Create User"

      expect(current_path).to eq(dashboard_path)

      expect(page).to have_content("Logged in as #{name}")
      expect(page).to have_content("This account has not yet been activated. Please check your email.")
    end

    it "fills in information incorrectly and clicks submit" do
      visit register_path

      email = "fake@fake.com"
      name = "Fakety fake fake"

      fill_in :user_email, with: email
      fill_in :user_name, with: name

      click_on "Create User"

      expect(current_path).to eq(users_path)
      expect(User.count).to eq(0)
    end

    it "fills out password and password confirmation with different information" do
      visit register_path

      email = "fake@fake.com"
      name = "Fakety fake fake"
      password = "1234"
      password_confirmation = "12345"

      fill_in :user_email, with: email
      fill_in :user_name, with: name
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: password_confirmation

      click_on "Create User"

      expect(current_path).to eq(users_path)
      expect(User.count).to eq(0)
    end
  end
end
