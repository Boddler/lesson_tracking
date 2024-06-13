class CreateUpdates < ActiveRecord::Migration[7.1]
  def change
    create_table :updates do |t|

      t.timestamps
    end
  end
end
