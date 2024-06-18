class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.references :scrape, foreign_key: true
      t.string :time
      t.date :date
      t.string :code
      t.string :ls
      t.string :text
      t.boolean :peak, default: false
      t.boolean :blue, default: false
      t.boolean :booked, default: false
      t.timestamps
    end
  end
end
