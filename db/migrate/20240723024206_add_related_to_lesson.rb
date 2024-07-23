class AddRelatedToLesson < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :related, :boolean, default: false

    change_column_default :lessons, :related, false
  end
end
