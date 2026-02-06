module Notifiable
  extend ActiveSupport::Concern

  included do
    scope :unread, -> { where(read_at: nil) }
    scope :recent, -> { order(created_at: :desc) }
    scope :for_user, ->(user) { where(user: user) }
    scope :for_company, ->(company) { where(company: company) }
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  def should_batch?
    settings = user.notification_setting_for(company)
    settings.email_batch_minutes.positive?
  end

  def in_quiet_hours?
    settings = user.notification_setting_for(company)
    current_time = Time.current.in_time_zone(settings.timezone)

    start_hour = settings.quiet_hours_start.hour
    start_min = settings.quiet_hours_start.min
    end_hour = settings.quiet_hours_end.hour
    end_min = settings.quiet_hours_end.min

    current_hour = current_time.hour
    current_min = current_time.min

    # Convert to minutes since midnight for easier comparison
    current_mins = current_hour * 60 + current_min
    start_mins = start_hour * 60 + start_min
    end_mins = end_hour * 60 + end_min

    if start_mins < end_mins
      # Quiet hours don't cross midnight
      current_mins >= start_mins && current_mins < end_mins
    else
      # Quiet hours cross midnight
      current_mins >= start_mins || current_mins < end_mins
    end
  end

  def send_notification!
    return if in_quiet_hours?

    subscription = user.notification_subscription_for(company, notification_type)

    # Only send if user is subscribed to at least one channel
    return unless subscription.enabled_channels.any?

    if should_batch?
      add_to_batch
    else
      deliver_immediately
    end
  end

  private

  def deliver_immediately
    subscription = user.notification_subscription_for(company, notification_type)

    if subscription.email_enabled
      NotificationMailer.with(notification: self).send_notification.deliver_later
    end

    # Future: Add SMS and push delivery here
    # if subscription.sms_enabled && user.phone_verified?
    #   SmsService.send_notification(self)
    # end
    #
    # if subscription.push_enabled
    #   PushService.send_notification(self)
    # end
  end

  def add_to_batch
    batch = NotificationBatch.find_or_create_pending_for(user, company)
    batch.add_notification(self)
  end
end