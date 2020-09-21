class User < ApplicationRecord
  validates :access_token, presence: true, uniqueness: true
  validates :email, presence: true

  has_many :pins, dependent: :destroy

  before_validation :set_access_token

  def set_access_token
    return if access_token.present?
    self.access_token = SecureRandom.hex(16)
  end
end
