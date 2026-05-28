class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient_employee, null: false, foreign_key: { to_table: :employees }
      t.integer :notification_type
      t.references :notifiable, polymorphic: true, null: false
      t.datetime :read_at
      t.text :message_text

      t.timestamps
    end
  end
end
