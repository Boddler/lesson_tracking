class ScrapesController < ApplicationController
  def create
    log_in
    @scrape = initial
    slots = info_pull_1
    lesson_save(slots)
    # info_pull_past
    # info_pull_future
  end

  private

  def initial
    today = Date.today
    # yyyymm = "202405"
    # yyyymm = "#{today.year}" + "#{0 if today.month < 10}" "#{today.month}".to_i
    yyyymm = "#{today.year}#{'0' if today.month < 10}#{today.month}".to_i
    user_id = params[:scrape][:user_id]
    last_update_no = Scrape.where(user_id: user_id).where(yyyymm: yyyymm).order(:created_at).last
    new_update_no = last_update_no ? last_update_no.update_no + 1 : 1
    instance = Scrape.new(
      yyyymm: yyyymm,
      user_id: user_id,
      update_no: new_update_no
    )
    instance.save
  end


  def log_in
    @mechanize = Mechanize.new
    login_form = @mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form
    login_form.username = params[:scrape][:user_id]
    login_form.password = params[:scrape][:password]
    @mechanize.submit(login_form, login_form.buttons.first)
  end

  def info_pull_1
    days = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=").search(".day")
    peak_times = ["07:00", "07:50", "08:40", "17:10", "18:00", "18:50", "19:40", "20:30", "21:20"]
    lessons = []
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
        lessons << lesson
      end
    end
    lessons
  end

  def lesson_save(lessons)
    lessons.each do |lesson|
      Lesson.create(lesson)
      puts lesson
    end
  end
end
