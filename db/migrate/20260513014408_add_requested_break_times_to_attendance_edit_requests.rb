class AddRequestedBreakTimesToAttendanceEditRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :attendance_edit_requests, :requested_break_started_at, :datetime
    add_column :attendance_edit_requests, :requested_break_finished_at, :datetime
  end
end
