require "rails_helper"

describe User, type: :model do
  describe "attributes" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:status) }
  end

  describe "instance methods" do
    describe "#confirm_registration" do
      it "changes status from inactive to active" do
        user = create(:user, status: "inactive")

        expect(user.status).to eq("inactive")

        user.confirm_registration
        expect(user.status).to eq("active")
      end
    end
  end
end
