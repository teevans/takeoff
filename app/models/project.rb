class Project < ApplicationRecord
  belongs_to :company

  PROJECT_TYPES = %w[new_build existing_build].freeze
  STATUSES = %w[planning active on_hold completed].freeze

  validates :name, presence: true
  validates :project_type, presence: true, inclusion: { in: PROJECT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :planning, -> { where(status: "planning") }
  scope :completed, -> { where(status: "completed") }
  scope :on_hold, -> { where(status: "on_hold") }
  scope :by_status, ->(status) { where(status: status) }
  scope :new_builds, -> { where(project_type: "new_build") }
  scope :existing_builds, -> { where(project_type: "existing_build") }
  scope :recent, -> { order(created_at: :desc) }

  def new_build?
    project_type == "new_build"
  end

  def existing_build?
    project_type == "existing_build"
  end

  def planning?
    status == "planning"
  end

  def active?
    status == "active"
  end

  def on_hold?
    status == "on_hold"
  end

  def completed?
    status == "completed"
  end

  def can_be_completed?
    active? && estimated_completion_date.present?
  end

  def mark_as_completed!
    update!(status: "completed")
  end

  def mark_as_active!
    update!(status: "active", start_date: Date.current) if start_date.blank?
    update!(status: "active") if start_date.present?
  end

  def put_on_hold!
    update!(status: "on_hold")
  end

  def formatted_budget
    return "Not set" if budget.blank?
    "$#{ActiveSupport::NumberHelper.number_to_delimited(budget)}"
  end

  def full_address
    return nil if address.blank?
    [address, city, state, zip_code].compact.join(", ")
  end

  def days_until_completion
    return nil if estimated_completion_date.blank?
    (estimated_completion_date - Date.current).to_i
  end

  def overdue?
    return false if estimated_completion_date.blank?
    estimated_completion_date < Date.current && !completed?
  end
end