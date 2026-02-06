module Tokenizable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
    scope :active, -> { where("expires_at > ?", Time.current) }
  end

  def expired?
    expires_at < Time.current
  end

  def active?
    !expired?
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at ||= 7.days.from_now
  end
end
