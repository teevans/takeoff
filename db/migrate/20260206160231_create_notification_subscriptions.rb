class CreateNotificationSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :notification_type, null: false, foreign_key: true
      t.boolean :email_enabled, default: true, null: false
      t.boolean :sms_enabled, default: false, null: false
      t.boolean :push_enabled, default: false, null: false

      t.timestamps
    end

    add_index :notification_subscriptions, 
              [:user_id, :company_id, :notification_type_id], 
              unique: true,
              name: 'index_notification_subs_on_user_company_type'
  end
end
