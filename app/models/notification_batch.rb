class NotificationBatch < ApplicationRecord
  belongs_to :user
  belongs_to :company

  scope :pending, -> { where(sent_at: nil) }
  scope :due, -> { pending.where("scheduled_for <= ?", Time.current) }

  def self.find_or_create_pending_for(user, company)
    settings = user.notification_setting_for(company)
    scheduled_time = Time.current + settings.email_batch_minutes.minutes

    pending.find_or_create_by(user: user, company: company) do |batch|
      batch.scheduled_for = scheduled_time
      batch.notifications = []
    end
  end

  def add_notification(notification)
    self.notifications ||= []
    self.notifications << {
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notification_type: notification.notification_type.name,
      created_at: notification.created_at.iso8601
    }
    save!
  end

  def deliver!
    return if sent?
    return if notifications.blank?

    NotificationMailer.with(batch: self).batch_notification.deliver_later
    update!(sent_at: Time.current)
  end

  def sent?
    sent_at.present?
  end

  # For accessing the actual notification records
  def notification_records
    return [] if notifications.blank?
    
    ids = notifications.map { |n| n["id"] || n[:id] }.compact
    Notification.where(id: ids)
  end
end