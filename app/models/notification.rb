class Notification < ApplicationRecord
  include Notifiable

  belongs_to :user
  belongs_to :company
  belongs_to :notification_type

  validates :title, presence: true
  validates :body, presence: true

  after_create :send_notification!

  # Helper method to create a notification from common patterns
  def self.notify!(user:, company:, type_key:, title:, body:, data: {})
    notification_type = NotificationType.find_by!(key: type_key)

    create!(
      user: user,
      company: company,
      notification_type: notification_type,
      title: title,
      body: body,
      data: data
    )
  end
end