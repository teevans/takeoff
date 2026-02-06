class CreateNotificationBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.json :notifications, default: []
      t.datetime :scheduled_for
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notification_batches, [:scheduled_for, :sent_at]
  end
end
