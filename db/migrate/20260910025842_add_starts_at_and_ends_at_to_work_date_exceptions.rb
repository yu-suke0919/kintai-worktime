class AddStartsAtAndEndsAtToWorkDateExceptions < ActiveRecord::Migration[8.1]
  def change
    add_column :work_date_exceptions, :starts_at, :datetime
    add_column :work_date_exceptions, :ends_at, :datetime
  end
end
