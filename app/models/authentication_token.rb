class AuthenticationToken < ApplicationRecord
  belongs_to :user

  TOKEN_EXPIRY = 15.minutes

  before_create :generate_token_and_code

  scope :active, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def self.find_by_valid_token(token)
    active.find_by(token: token)
  end

  def self.find_by_valid_code(code, user_id)
    active.find_by(code: code.upcase, user_id: user_id)
  end

  def use!
    update!(used_at: Time.current)
  end

  def used?
    used_at.present?
  end

  def expired?
    expires_at < Time.current
  end

  def is_valid?
    !used? && !expired?
  end

  private

  def generate_token_and_code
    self.token = SecureRandom.urlsafe_base64(32)
    self.code = generate_unique_code
    self.expires_at = TOKEN_EXPIRY.from_now
  end

  def generate_unique_code
    loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless self.class.active.exists?(code: code)
    end
  end
end