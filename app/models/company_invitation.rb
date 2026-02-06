class CompanyInvitation < ApplicationRecord
  include Tokenizable

  belongs_to :company
  belongs_to :invited_by, class_name: "User"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[administrator member] }

  scope :for_email, ->(email) { where(email: email.downcase) }
  scope :pending, -> { active }

  normalizes :email, with: ->(e) { e.strip.downcase }

  def redeem_for(user)
    return false if expired?

    transaction do
      company.company_users.create!(user: user, role: role)
      destroy
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def send_invitation_email
    CompanyInvitationMailer.with(invitation: self).invite.deliver_later
  end
end
