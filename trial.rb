require "mechanize"
require "date"
require "nokogiri"
require "dotenv"
Dotenv.load

mechanize = Mechanize.new
login_form = mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form

login_form.username = ENV["USERNAME"]
login_form.password = ENV["PASSWORD"]
mechanize.submit(login_form, login_form.buttons.first)

schedule_management = mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")

days = schedule_management.search(".day")
month = schedule_management.css("p.month").text.strip

def save(lesson)
  pp lesson
end

days.each do |day|
  date = day.css("a.day-link").text.strip.to_i
  slots = day.search(".booking")
  peak = day.classes.include?("weekend")
  slots.each do |slot|
    lesson = {}
    str = slot.text.strip if date == 18
    next if str.nil?
    lesson[:time] = slot.css(".time").text.strip
    lesson[:ls] = slot.css(".school").text.strip
    lesson[:text] = slot.css(".textbookname").text.strip
    lesson[:blue] = slot.classes.include?("client")
    lesson[:peak] = peak
    save(lesson)
  end
end

# Identify & store the month
# iterate through each day and create lessons
# is the first of the month included?
# go back to the previous week and iterate again
# is the first of the month included?

# open
# booked
#

# x.any? { |y| y.text.strip == "1" }
# y = 1
# x.each do |element|
#   pp y
#   pp element.text.strip
#   pp element.text.strip == "22"
#   y += 1
#   puts "*" * 40
# end

# booked = schedule_management.search(".booking.lesson")
# counsellor = schedule_management.search(".booking.counselor")
# blue = schedule_management.search(".booking.client")
# r = schedule_management.search(".booking.related")

# puts "Red/Black Lessons: #{booked.size}"
# puts "Green Lessons: #{counsellor.size}"
# puts "Blue Lessons: #{blue.size}"
# puts "Rs: #{r.size}"
# puts "Total: #{booked.size + counsellor.size + blue.size + r.size}"
