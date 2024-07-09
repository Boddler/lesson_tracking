class Scrape < ApplicationRecord
  has_many :slots, dependent: :destroy
  has_many :lessons, through: :slots

  def add_lesson(attributes)
    lesson = Lesson.find_or_create_by_attributes(attributes)
    slots.find_or_create_by(lesson: lesson)
  end
end
