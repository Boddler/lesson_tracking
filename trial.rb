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

# scrape = Scrape.new

schedule_management = mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")

days = schedule_management.search(".day")

peak_times = ["07:00", "07:50", "08:40", "17:10", "18:00", "18:50", "19:40", "20:30", "21:20"]

def lesson(lesson)
  pp lesson
end

def scrape(scrape)
  pp scrape
end

def days(days, peak_times)
  update
  days.reverse.each do |day|
    date = day.css("a.day-link").text.strip.to_i
    slots = day.search(".booking")
    peak = day.classes.include?("weekend")
    year = Date.today.year
    slots.each do |slot|
      lesson = {}
      str = slot.text.strip if date == 18
      next if str.nil?
      lesson[:time] = slot.css(".time").text.strip
      date_str = slot.css(".date-time").text.strip[0, 6]
      lesson[:date] = Date.parse("#{date_str} #{year}")
      lesson[:code] = slot.css(".type").text.strip
      lesson[:ls] = slot.css(".school").text.strip
      lesson[:text] = slot.css(".textbookname").text.strip
      peak ||= peak_times.include?(lesson[:time])
      lesson[:peak] = peak
      lesson[:blue] = slot.classes.include?("client")
      lesson[:booked] = !slot.classes.include?("available")
      lesson(lesson)
    end
  end
end

def past
end

def update
  scrape = {}
  today = Date.today
  scrape[:yyyymm] = "#{today.year}" + "#{0 if today.month < 10}" "#{today.month}"
  scrape[:user_id] = ENV["USERNAME"]
  scrape[:update_no] = 1
  scrape(scrape)
end

days(days, peak_times)

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
