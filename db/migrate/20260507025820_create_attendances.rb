class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :worked_on
      t.integer :status
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :break_started_at
      t.datetime :break_finished_at

      t.timestamps
    end
  end
end
