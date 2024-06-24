class Slot < ApplicationRecord
  belongs_to :scrape
  belongs_to :lesson
  before_save :check_for_changes

  def check_for_changes
    existing_record = Slot.exists?(scrape_id: scrape_id - 1, lesson_id: lesson_id)
    self.updated = !existing_record
  end
end
