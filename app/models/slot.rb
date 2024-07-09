class Slot < ApplicationRecord
  belongs_to :scrape
  belongs_to :lesson
  before_save :check_for_changes
  validates :lesson_id, presence: true

  def check_for_changes
    scrape = Scrape.find(scrape_id)
    previous_update_no = scrape.update_no - 1
    existing_record = Slot.joins(:scrape)
                          .where(scrapes: { update_no: previous_update_no }, lesson_id: lesson_id)
                          .exists?
    self.updated = !existing_record
  end
end
