class RemoveEditTypeFromAttendanceEditRequest < ActiveRecord::Migration[8.1]
  def change
    remove_column :attendance_edit_requests, :edit_type, :integer
  end
end
