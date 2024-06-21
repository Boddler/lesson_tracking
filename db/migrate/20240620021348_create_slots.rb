class CreateSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :slots do |t|
      t.references :scrape, foreign_key: true
      t.references :lesson, foreign_key: true
      t.timestamps
    end
  end
end
