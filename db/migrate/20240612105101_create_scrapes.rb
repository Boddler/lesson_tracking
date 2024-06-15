class CreateScrapes < ActiveRecord::Migration[7.1]
  def change
    create_table :scrapes do |t|
      t.integer :yymm
      t.string :user_id
      t.integer :update_no
      t.timestamps
    end
  end
end
