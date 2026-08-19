class CreateMonthlyAttendanceClosingApprovals < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_attendance_closing_approvals do |t|
      t.references :approver, null: false, foreign_key: { to_table: :employees }
      t.references :monthly_attendance_closing, null: false, foreign_key: true

      t.integer :status, null: false
      t.integer :approval_order, null: false
      t.text :reason
      t.timestamps

      t.index [ :approver_id, :status ]# その管理人がやるべき要承認リストを作る時、これがないと親テーブルまで行って探索する必要が出てくるため作成
      t.index [ :monthly_attendance_closing, :approval_order ], unique: true
    end
  end
end
