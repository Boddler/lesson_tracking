start = Time.now
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

def weekly_parse(web_page)
  peak_times = ["07:00", "07:50", "08:40", "17:10", "18:00", "18:50", "19:40", "20:30", "21:20"]
  lessons = []
  month = web_page.css(".month").text.strip
  year = web_page.css(".year").text.strip
  days = web_page.search(".day")
  days.reverse.each do |day|
    slots = day.search(".booking")
    peak = day.classes.include?("weekend")
    day_name = day.css(".day-link").text.strip.split.first
    slots.each do |slot|
      str = slot.text.strip
      next if str.nil?

      lesson = {}
      lesson[:time] = slot.css(".time").text.strip
      lesson[:date] = Date.parse(day_name + " " + month + " " + year)
      lesson[:ls] = slot.css(".school").text.strip
      lesson[:text] = slot.css(".textbookname").text.strip
      lesson[:peak] = peak || peak_times.include?(lesson[:time])
      lesson[:blue] = slot.classes.include?("client")
      lesson[:related] = slot.classes.include?("related")
      lesson[:booked] = !slot.classes.include?("available")
      lesson[:code] = slot.css(".type").text.strip if lesson[:booked]
      lessons << lesson
    end
  end
  lessons
end

# pull main schedule page
page = mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
# follow link to monthly view
link = mechanize.click(page.at(".day-desc a"))
# follw link to previous month
previous = mechanize.click(link.at("#previousLink"))
# create array of elements
# iterate through the elements to create the lessons

lessons = weekly_parse(previous)

# lessons.each do |lesson|
#   pp lesson[:date]
#   pp lesson[:time]
#   puts "*" * 25
# end

pp lessons[-9]

finish = Time.now

puts "Everything took #{finish - start} seconds"
