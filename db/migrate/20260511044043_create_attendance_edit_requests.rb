class CreateAttendanceEditRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_edit_requests do |t|
      t.references :attendance, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.integer :approved_by_id
      t.datetime :approved_at
      t.integer :status
      t.integer :edit_type
      t.datetime :requested_started_at
      t.datetime :requested_finished_at
      t.text :reason

      t.timestamps
    end
  end
end
