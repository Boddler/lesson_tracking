class CreateScrapes < ActiveRecord::Migration[7.1]
  def change
    create_table :scrapes do |t|
      t.integer :yyyymm
      t.string :user_id
      t.integer :update_no
      t.references :pull, foreign_key: true
      t.timestamps
    end
  end
end
