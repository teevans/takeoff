class CompanyUser < ApplicationRecord
  belongs_to :company
  belongs_to :user

  validates :role, inclusion: { in: %w[administrator member] }
  validates :user_id, uniqueness: { scope: :company_id, message: "is already a member of this company" }

  scope :administrators, -> { where(role: "administrator") }
  scope :members, -> { where(role: "member") }

  def administrator?
    role == "administrator"
  end

  def member?
    role == "member"
  end
end
