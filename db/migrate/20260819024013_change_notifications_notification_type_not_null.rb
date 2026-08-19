class ChangeNotificationsNotificationTypeNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :notifications, :notification_type, false
  end
end
