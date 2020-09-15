class User < ApplicationRecord
  validates :access_token, presence: true, uniqueness: true
  validates :email, presence: true

  has_many :pins
end
