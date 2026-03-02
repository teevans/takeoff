class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :authentication_tokens, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
                           uniqueness: { case_sensitive: false },
                           format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
end
