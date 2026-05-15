class AddOriginalTimeColumnsToAttendances < ActiveRecord::Migration[8.1]
  def up
    add_column :attendances, :original_started_at, :datetime
    add_column :attendances, :original_finished_at, :datetime
    add_column :attendances, :original_break_started_at, :datetime
    add_column :attendances, :original_break_finished_at, :datetime
    execute <<~SQL
      UPDATE attendances
      SET
        original_started_at = started_at,
        original_finished_at = finished_at,
        original_break_started_at = break_started_at,
        original_break_finished_at = break_finished_at
    SQL
  end

  def down
    remove_column :attendances, :original_started_at
    remove_column :attendances, :original_finished_at
    remove_column :attendances, :original_break_started_at
    remove_column :attendances, :original_break_finished_at
  end
end
