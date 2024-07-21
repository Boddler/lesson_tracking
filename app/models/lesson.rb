class Lesson < ApplicationRecord
  has_many :slots
  has_many :scrapes, through: :slots
  before_save :check_for_text

  def check_for_text
    self.text = "Unknown" if booked && text.blank?
  end

  def self.find_or_create_by_attributes(attributes)
    sanitised_attributes = attributes.except("id", "created_at", "updated_at")
    Lesson.find_by(sanitised_attributes) || Lesson.create(sanitised_attributes)
  end
end
