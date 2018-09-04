class User < ApplicationRecord
  has_secure_password
  has_secure_token :auth_token

  validates_presence_of :name, uniqueness: true, presence: true
  validates_presence_of :password, require: true, allow_nil: true
  validates :password, confirmation: { case_sensitive: true }
  validates_presence_of :email, uniqueness: true

  validates_presence_of :status

  enum status: [:inactive, :active]

  def confirm_registration
    update_attributes(status: "active") if self.status == "inactive"
  end
end
