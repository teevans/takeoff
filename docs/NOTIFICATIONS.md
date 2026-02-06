# Notification System Documentation

## Overview
The notification system provides a flexible, multi-channel notification framework for sending notifications to users. It supports email notifications (with SMS and push channels ready for future implementation), batching, quiet hours, and per-user/per-company subscription preferences.

## Architecture

### Core Models
- **Notification**: Individual notification instances sent to users
- **NotificationType**: Predefined notification types (e.g., project_created, user_invited)
- **NotificationSubscription**: User's subscription preferences per notification type per company
- **NotificationBatch**: Groups notifications for batch email delivery
- **UserNotificationSetting**: User's delivery preferences (batch time, quiet hours, timezone)

## Adding New Notification Types

### 1. Define the Notification Type
Add your new notification type to `config/notifications.yml`:

```yaml
notification_types:
  your_notification_key:
    name: "Human Readable Name"
    category: "project|team|system"
    description: "When this notification is sent"
    channels: ["email", "sms", "push"]  # Available channels
    default_enabled: true                # Auto-subscribe new users
    force_enabled: false                 # Can users unsubscribe?
```

### 2. Load the Notification Type
Run the seed command to load your new notification type:
```bash
rails db:seed
```

### 3. Send Notifications in Your Code

#### From a Controller
```ruby
class ProjectsController < ApplicationController
  def create
    @project = Current.company.projects.build(project_params)
    
    if @project.save
      # Send to specific users
      Current.company.users.find_each do |user|
        user.notify!(
          company: Current.company,
          type_key: 'project_created',
          title: "New Project: #{@project.name}",
          body: "A new project has been created.",
          data: { project_id: @project.id }
        )
      end
    end
  end
end
```

#### From a Model
```ruby
class Project < ApplicationRecord
  after_create :notify_administrators
  
  private
  
  def notify_administrators
    company.administrators.find_each do |admin|
      admin.notify!(
        company: company,
        type_key: 'project_created',
        title: "New Project: #{name}",
        body: "#{creator.name} created a new project.",
        data: { project_id: id }
      )
    end
  end
end
```

## Email Batching
Notifications are automatically batched based on user preferences:
- Default batch time: 15 minutes
- Users can set: Immediate, 5, 15, 30, or 60 minutes
- Run the batch processor job regularly:
  ```ruby
  # Add to your job scheduler (e.g., whenever, sidekiq-cron)
  ProcessNotificationBatchesJob.perform_later
  ```

## Quiet Hours
Notifications respect user-defined quiet hours:
- Default: 7PM to 7AM in user's timezone
- Force-enabled notifications (security alerts) bypass quiet hours
- Notifications during quiet hours are queued for delivery

## User Settings

### Notification Settings Page
Users can access their notification settings at `/notification_settings` to:
- Enable/disable specific notification types
- Choose delivery channels (email, SMS, push)
- Configure batch timing
- Set quiet hours and timezone

### Notification Center
Users can view all notifications at `/notification_center`:
- See unread notifications
- Mark individual or all as read
- Filter by category
- View notification history

## Adding SMS Support (Future)

When ready to add SMS support:

1. Add Twilio credentials to Rails credentials:
```bash
rails credentials:edit
```

2. Add Twilio gem to Gemfile:
```ruby
gem 'twilio-ruby'
```

3. Create SMS delivery method in Notification model:
```ruby
def deliver_via_sms!
  return unless user.phone_verified?
  
  TwilioClient.messages.create(
    from: Rails.application.credentials.twilio[:phone_number],
    to: user.phone_number,
    body: "#{title}\n#{body}"
  )
end
```

4. Update the notification delivery logic to check SMS subscriptions

## Adding Push Notifications (Future)

When ready to add push notifications:

1. Create DeviceToken model:
```ruby
class DeviceToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true, uniqueness: true
  validates :platform, inclusion: { in: %w[ios android web] }
end
```

2. Add push notification service (e.g., FCM, APNS):
```ruby
def deliver_via_push!
  user.device_tokens.each do |device|
    PushNotificationService.send(
      token: device.token,
      platform: device.platform,
      title: title,
      body: body,
      data: data
    )
  end
end
```

## Testing Notifications

### In Rails Console
```ruby
# Find a user and company
user = User.find_by(email_address: 'demo@example.com')
company = Company.first

# Send a test notification
user.notify!(
  company: company,
  type_key: 'project_created',
  title: 'Test Notification',
  body: 'This is a test notification.',
  data: { test: true }
)

# Check if it was created
user.notifications.last
```

### Check Subscription Status
```ruby
# Check user's subscriptions for a company
user.notification_subscriptions.where(company: company)

# Check if user is subscribed to a specific type
type = NotificationType.find_by(key: 'project_created')
sub = user.notification_subscription_for(company, type)
sub.email_enabled?
```

## Available Notification Types

Current notification types defined in the system:
- **project_created**: When a new project is created
- **project_completed**: When a project is marked complete
- **project_status_changed**: When project status updates
- **user_invited**: When someone is invited to join
- **user_joined**: When someone accepts an invitation
- **user_removed**: When someone is removed
- **security_alert**: Important security notifications (force-enabled)
- **system_maintenance**: Scheduled maintenance notices

## Best Practices

1. **Always use predefined notification types** - Don't create ad-hoc notifications
2. **Include relevant data** - Pass IDs and context in the data hash
3. **Keep titles concise** - Titles should be scannable
4. **Respect user preferences** - Check subscriptions before sending
5. **Use appropriate categories** - This helps users filter notifications
6. **Test quiet hours** - Ensure time-sensitive notifications are marked appropriately
7. **Document new types** - Update notifications.yml with clear descriptions