class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :company

  delegate :user, to: :session, allow_nil: true

  resets { self.company = nil }

  def user
    session&.user
  end

  def user=(user)
    super
    self.company = user.companies.first if user && !company
  end
end
