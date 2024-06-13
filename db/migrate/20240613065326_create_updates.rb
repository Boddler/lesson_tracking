class CreateUpdates < ActiveRecord::Migration[7.1]
  def change
    create_table :updates do |t|
      t.integer :yymm
      t.string :user_id
      t.integer :update_no
      t.timestamps
    end
  end
end
