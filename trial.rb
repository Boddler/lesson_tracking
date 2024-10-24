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

page = mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
pp page.links[-1]

30.times do
  puts "*"
end
# dates = page.search(".day-desc")

# pp dates[1].text.strip[0, 2].to_i > dates[7].text.strip[0, 2].to_i

# puts "#{dates[1].text.strip[0, 2]} is the first date and #{dates[7].text.strip[0, 2]} is the last"

schedule = mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
link = schedule.at(".day-desc a")

pp mechanize.click(link).links[-1]

# days.each do |day|
#   # pp day.search(".date-time").text.strip[0, 6].split(" ").last.to_i
#   pp Date::ABBR_MONTHNAMES.index(day.search(".date-time").text.strip[0, 6].split(" ").first)
# end


# root = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
# past = []
# x = 1
# until x == 10
#   link = root.at("a.pull-left")
#   previous_page = @mechanize.click(link)
