class NotificationSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :notification_type

  validates :user_id, uniqueness: { scope: [:company_id, :notification_type_id] }

  def enabled_channels
    channels = []
    channels << :email if email_enabled
    channels << :sms if sms_enabled && user.phone_verified?
    channels << :push if push_enabled
    channels
  end

  def update_channel(channel, enabled)
    case channel.to_sym
    when :email
      update!(email_enabled: enabled)
    when :sms
      if user.phone_verified?
        update!(sms_enabled: enabled)
      else
        errors.add(:base, "Phone number must be verified to enable SMS notifications")
        false
      end
    when :push
      update!(push_enabled: enabled)
    else
      errors.add(:base, "Unknown channel: #{channel}")
      false
    end
  end
end