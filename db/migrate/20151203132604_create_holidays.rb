class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.string :name
      t.date :on_date
      t.integer :days, default: 1

      t.timestamps
    end
  end
end
