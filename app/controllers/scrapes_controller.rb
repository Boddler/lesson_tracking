class ScrapesController < ApplicationController
  def results
    Slot.destroy_all
    Scrape.destroy_all
    Lesson.destroy_all
    log_in
    @scrape = start
    current = info_pull_1
    past = info_pull_past
    future = info_pull_future
    all = current + past + future
    lesson_save(all)
    session[:scrape_id] = @scrape.id
    redirect_to :display
  end

  def display
    scrape = Scrape.find(session[:scrape_id])
    @all = Scrape.where(user_id: scrape.user_id)
  end

  private

  def start
    today = Date.today
    yyyymm = "#{today.year}#{"0" if today.month < 10}#{today.month}".to_i
    user_id = params[:scrape][:user_id]
    last_update_no = Scrape.where(user_id: user_id).where(yyyymm: yyyymm).order(:created_at).last
    new_update_no = last_update_no ? last_update_no.update_no + 1 : 1
    instance = Scrape.new(
      yyyymm: yyyymm,
      user_id: user_id,
      update_no: new_update_no,
    )
    instance.save
    instance
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
      slots = day.search(".booking")
      peak = day.classes.include?("weekend")
      year = Date.today.year
      slots.each do |slot|
        lesson = {}
        str = slot.text.strip
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

  def info_pull_past
    []
  end

  def info_pull_future
    []
  end

  def lesson_save(lessons)
    lessons.each do |lesson|
      @scrape.add_lesson(lesson)
    end
  end

  # def slots_save(x)
  #   info = {
  #     scrape_id: @scrape.id,
  #     lesson_id: x.id,
  #   }
  #   slot = Slot.new(info)
  #   if slot.save
  #     puts "Slot saved successfully"
  #   else
  #     puts "#{x.errors.full_messages}"
  #   end
  # end
end
