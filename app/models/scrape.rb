class Scrape < ApplicationRecord
  has_many :slots, dependent: :destroy
  has_many :lessons, through: :slots

  def add_lesson(attributes)
    lesson = Lesson.find_or_create_by(attributes)

    if lesson.persisted?
      slot = slots.find_or_create_by(lesson: lesson)
      if slot.persisted?
        logger.info "Slot created successfully: #{slot.inspect}"
      else
        logger.error "Failed to create slot: #{slot.errors.full_messages.join(", ")}"
      end
      slot
    else
      logger.error "Failed to create or find lesson: #{lesson.errors.full_messages.join(", ")}"
      nil
    end
  end

  def lesson_count
    current_month = Date.today.month
    blues = slots.joins(:lesson)
                 .where(lessons: { booked: true, blue: true })
                 .where("EXTRACT(MONTH FROM date) = ?", current_month)
                 .count
    reds = slots.joins(:lesson)
                .where(lessons: { booked: true, blue: false })
                .where("EXTRACT(MONTH FROM date) = ?", current_month)
                .count
    # total = blues + reds
    comp_this ||= {}
    comp_this[:reds] = reds
    comp_this[:blues] = blues
    puts "Comp_this: #{comp_this}"
    update_attribute(:comp_this, comp_this)
    if save
      "Saved!"
    else
      puts "Error updating lesson count: #{errors.full_messages.join(", ")}"
    end
  end
end
