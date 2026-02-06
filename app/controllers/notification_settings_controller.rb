class NotificationSettingsController < ApplicationController

  def index
    @notification_types = NotificationType.order(:category, :name)
    @subscriptions = Current.user.notification_subscriptions
                                 .where(company: Current.company)
                                 .index_by(&:notification_type_id)
    @settings = Current.user.notification_setting_for(Current.company)
    
    render inertia: 'notification_settings/index', props: {
      notification_types: @notification_types.map { |type| serialize_notification_type(type) },
      subscriptions: @subscriptions.transform_keys(&:to_s).transform_values { |sub| serialize_subscription(sub) },
      settings: serialize_settings(@settings)
    }
  end

  def update_subscription
    notification_type = NotificationType.find(params[:notification_type_id])
    subscription = Current.user.notification_subscriptions
                               .find_or_initialize_by(
                                 notification_type: notification_type,
                                 company: Current.company
                               )
    
    if notification_type.force_enabled?
      redirect_to notification_settings_path, 
                  inertia: { errors: { base: "This notification cannot be disabled" } }
      return
    end

    subscription.assign_attributes(subscription_params)
    
    if subscription.save
      redirect_to notification_settings_path
    else
      redirect_to notification_settings_path, 
                  inertia: { errors: subscription.errors }
    end
  end

  def update_settings
    @settings = Current.user.notification_setting_for(Current.company)
    
    if @settings.update(settings_params)
      redirect_to notification_settings_path
    else
      redirect_to notification_settings_path, 
                  inertia: { errors: @settings.errors }
    end
  end

  private

  def subscription_params
    params.permit(:email_enabled, :sms_enabled, :push_enabled)
  end

  def settings_params
    params.permit(:email_batch_minutes, :quiet_hours_start, :quiet_hours_end, :timezone)
  end

  def serialize_notification_type(type)
    {
      id: type.id,
      key: type.key,
      name: type.name,
      description: type.description,
      category: type.category,
      channels: type.channels,
      default_enabled: type.default_enabled,
      force_enabled: type.force_enabled
    }
  end

  def serialize_subscription(subscription)
    {
      id: subscription.id,
      notification_type_id: subscription.notification_type_id,
      email_enabled: subscription.email_enabled,
      sms_enabled: subscription.sms_enabled,
      push_enabled: subscription.push_enabled
    }
  end

  def serialize_settings(settings)
    {
      id: settings.id,
      email_batch_minutes: settings.email_batch_minutes,
      quiet_hours_start: settings.quiet_hours_start.strftime("%H:%M"),
      quiet_hours_end: settings.quiet_hours_end.strftime("%H:%M"),
      timezone: settings.timezone
    }
  end
end