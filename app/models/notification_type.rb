class NotificationType < ApplicationRecord
  has_many :notification_subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, presence: true

  scope :by_category, ->(category) { where(category: category) }
  scope :subscribable, -> { where(force_enabled: false) }

  # Class method to register new notification types
  def self.register(key:, name:, description: nil, category:, channels: ["email"], default_enabled: true, force_enabled: false)
    find_or_create_by!(key: key) do |notification_type|
      notification_type.name = name
      notification_type.description = description
      notification_type.category = category
      notification_type.channels = channels
      notification_type.default_enabled = default_enabled
      notification_type.force_enabled = force_enabled
    end
  end

  def subscribable?
    !force_enabled
  end

  def available_channels
    channels || ["email"]
  end
end