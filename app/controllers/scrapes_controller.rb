class ScrapesController < ApplicationController
  def results
    # Slot.destroy_all
    # Scrape.destroy_all
    # Lesson.destroy_all
    log_in
    day = Date.today.months_ago(1)
    3.times do
      @scrape = start(day)
      current = info_pull1
      past = info_pull_past
      future = info_pull_future
      all = current + past + future
      trimmed_lsns = month_cut(all, day)
      lesson_save(trimmed_lsns)
      @scrape.lesson_count(day)
      day = day.next_month
    end
    session[:scrape_id] = @scrape.id
    # @scrape.lesson_count(Date.today.next_month)
    redirect_to :display
  end

  def month_cut(lessons, day)
    lessons.select { |lesson| lesson[:date].month == day.month }
  end

  def display
    scrape = Scrape.last
    # scrape = Scrape.find(session[:scrape_id])
    users_scrapes = Scrape.where(user_id: scrape.user_id)
    prep = users_scrapes.sort_by(&:created_at)
    @scrapes_array = prep.group_by(&:yyyymm)
    # Need to make the summary array
    # @summaries = prep.sort_by {}
  end

  private

  def start(day)
    yyyymm = "#{day.year}#{"0" if day.month < 10}#{day.month}".to_i
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

  def info_pull1
    days = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=").search(".day")
    weekly_parse(days)
  end

  def info_pull_past
    root = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
    past = []
    x = 1
    until x == 10
      link = root.at("a.pull-left")
      previous_page = @mechanize.click(link)
      x += 1
      parsed_data = weekly_parse(previous_page.search(".day"))
      past.concat(parsed_data) if parsed_data.is_a?(Array)
      root = previous_page
      dates = previous_page.search(".day-desc")
      break if dates[1].text.strip[0, 2].to_i > dates[7].text.strip[0, 2].to_i
    end
    past
  end

  def info_pull_future
    root = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
    future = []
    x = 1
    until x == 10
      link = root.at("a.pull-right")
      break if link.nil?

      next_page = @mechanize.click(link)
      x += 1
      parsed_data = weekly_parse(next_page.search(".day"))
      future.concat(parsed_data) if parsed_data.is_a?(Array)
      root = next_page
    end
    future
  end

  def weekly_parse(web_page)
    peak_times = ["07:00", "07:50", "08:40", "17:10", "18:00", "18:50", "19:40", "20:30", "21:20"]
    lessons = []
    web_page.reverse.each do |day|
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
        lesson[:ls] = slot.css(".school").text.strip
        lesson[:text] = slot.css(".textbookname").text.strip
        peak ||= peak_times.include?(lesson[:time])
        lesson[:peak] = peak
        lesson[:blue] = slot.classes.include?("client")
        lesson[:booked] = !slot.classes.include?("available")
        lesson[:code] = slot.css(".type").text.strip if lesson[:booked]
        lessons << lesson
      end
    end
    lessons
  end

  def lesson_save(lessons)
    lessons.each do |lesson|
      @scrape.add_lesson(lesson)
    end
  end
end
