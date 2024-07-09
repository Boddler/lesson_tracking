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

dates = page.search(".day-desc")

pp dates[1].text.strip[0, 2].to_i > dates[7].text.strip[0, 2].to_i

puts "#{dates[1].text.strip[0, 2]} is the first date and #{dates[7].text.strip[0, 2]} is the last"
