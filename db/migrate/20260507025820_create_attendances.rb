class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :worked_on, null: false
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :break_started_at
      t.datetime :break_finished_at

      t.timestamps
    end
    add_index :attendances, [ :employee_id, :worked_on ], unique: true
  end
end
