class UserNotificationSetting < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :email_batch_minutes, numericality: { greater_than_or_equal_to: 0 }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
  validates :user_id, uniqueness: { scope: :company_id }

  before_validation :set_defaults, on: :create

  def instant_notifications?
    email_batch_minutes.zero?
  end

  def quiet_hours_active?
    return false if quiet_hours_start.nil? || quiet_hours_end.nil?

    current_time = Time.current.in_time_zone(timezone)
    current_hour = current_time.hour
    current_min = current_time.min

    start_hour = quiet_hours_start.hour
    start_min = quiet_hours_start.min
    end_hour = quiet_hours_end.hour
    end_min = quiet_hours_end.min

    # Convert to minutes since midnight
    current_mins = current_hour * 60 + current_min
    start_mins = start_hour * 60 + start_min
    end_mins = end_hour * 60 + end_min

    if start_mins < end_mins
      current_mins >= start_mins && current_mins < end_mins
    else
      current_mins >= start_mins || current_mins < end_mins
    end
  end

  private

  def set_defaults
    self.email_batch_minutes ||= 15
    self.quiet_hours_start ||= Time.parse("19:00")
    self.quiet_hours_end ||= Time.parse("07:00")
    self.timezone ||= "UTC"
  end
end