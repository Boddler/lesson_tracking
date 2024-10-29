class Slot < ApplicationRecord
  belongs_to :scrape
  belongs_to :lesson
  before_save :check_for_changes
  # validates :lesson_id, presence: true

  def check_for_changes
    scrape = Scrape.find(scrape_id)
    previous_update_no = scrape.update_no - 1
    existing_record = Slot.joins(:scrape)
                          .where(scrapes: { update_no: previous_update_no, user_id: scrape.user_id }, lesson_id: lesson_id)
                          .exists?
    self.updated = !existing_record
  end

  def matching_lesson
    return unless updated && !lesson.booked

    previous_scrape = Scrape.find_by(update_no: scrape.update_no - 1, yyyymm: scrape.yyyymm, user_id: scrape.user_id)
    return unless previous_scrape

    Lesson.joins(:slots)
          .where(slots: { scrape_id: previous_scrape.id })
          .where(date: lesson.date, time: lesson.time)
          .first
  end
end

# Maybe...
#     prev_record = Slot.joins(:scrape)
# .where(scrapes: { update_no: previous_update_no, user_id: scrape.user_id }, lesson_id: lesson_id)
# .exists?
# self.updated = !prev_record unless (lesson.date + 1) < prev_record.lesson.updated_at
