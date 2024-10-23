class ScrapesController < ApplicationController
  def create
    submission = log_in
    @pull = Pull.find(params[:pull_id])
    if submission.links[0].text == "INSTRUCTOR PROFILE"
      day = Date.today.months_ago(1)
      3.times do
        @scrape = start(day)
        # Identify the last scrape for this month
        last_scrape = Scrape.all.where(user_id: @scrape.user_id).where(yyyymm: @scrape.yyyymm).last
        # send its creation date to the pull
        current = info_pull1(day, last_scrape.created_at)
        if last_scrape && last_scrape.created_at > day.end_of_month
          past = []
        else
          past = info_pull_past(day)
        end
        future = info_pull_future(day)
        all = current + past + future
        trimmed_lsns = month_cut(all, day)
        lesson_save(trimmed_lsns)
        @scrape.lesson_count(day)
        day = day.next_month
      end
      session[:scrape_id] = @scrape.id
      session[:user_id] = @scrape.user_id
      redirect_to scrapes_path
    else
      flash[:notice] = "Log in failed - please retry"
      redirect_to root_path
    end
  end

  def index
    user_id = session[:user_id]
    users_scrapes = Scrape.where(user_id: user_id)
    prep = users_scrapes.sort_by(&:created_at)
    updated_arrays = prep.reject { |scrape| scrape.slots.all? { |slot| slot.updated == false } }
    @scrapes_array = updated_arrays.group_by(&:yyyymm).sort_by { |array| array[0] }.reverse
    prep = prep.group_by(&:yyyymm).sort_by { |array| array[0] }.reverse
    @recent = []
    count = 0
    6.times do
      @recent << prep[count][-1][-1] if prep[count]
      count += 1
    end
  end

  private

  def month_cut(lessons, day)
    lessons.select { |lesson| lesson[:date].month == day.month }
  end

  def start(day)
    yyyymm = "#{day.year}#{"0" if day.month < 10}#{day.month}".to_i
    user_id = params[:user_id]
    pull = Pull.find(params[:pull_id])
    last_update = Scrape.where(user_id: user_id).where(yyyymm: yyyymm).order(:created_at).last
    new_update_no = last_update ? last_update.update_no + 1 : 1
    instance = Scrape.new(
      yyyymm: yyyymm,
      user_id: user_id,
      update_no: new_update_no,
      pull: pull,
    )
    instance.save
    instance
  end

  def log_in
    @mechanize = Mechanize.new
    login_form = @mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form
    login_form.username = params[:user_id]
    login_form.password = params[:password]
    @mechanize.submit(login_form, login_form.buttons.first)
  end

  def info_pull1(date, last_scrape_date)
    days = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=").search(".day")
    desired_days = []
    days.each do |day|
      date_text = day.search(".date-time").text.strip.split(" ")
      month = Date::ABBR_MONTHNAMES.index(date_text.first)
      day_number = date_text.last.to_i
      desired_days << day if month >= Date.today.month && day_number >= last_scrape_date.day
      # problem as it rejects next month's days if lower than last_scrape_date.day
      # Eg Dec 10th gets rejected if Nov 29th was the last scrape date
    end
    weekly_parse(desired_days, date)
  end

  def info_pull_past(date)
    root = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
    past = []
    x = 1
    until x == 10
      link = root.at("a.pull-left")
      previous_page = @mechanize.click(link)
      x += 1
      parsed_data = weekly_parse(previous_page.search(".day"), date)
      past.concat(parsed_data) if parsed_data.is_a?(Array)
      root = previous_page
    end
    past
  end

  def info_pull_future(date)
    root = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
    future = []
    x = 1
    until x == 10
      link = root.at("a.pull-right")
      break if link.nil?

      next_page = @mechanize.click(link)
      x += 1
      parsed_data = weekly_parse(next_page.search(".day"), date)
      future.concat(parsed_data) if parsed_data.is_a?(Array)
      root = next_page
    end
    future
  end

  def weekly_parse(web_page, date)
    peak_times = ["07:00", "07:50", "08:40", "17:10", "18:00", "18:50", "19:40", "20:30", "21:20"]
    lessons = []
    web_page.reverse.each do |day|
      slots = day.search(".booking")
      peak = day.classes.include?("weekend")
      year = date.year
      slots.each do |slot|
        str = slot.text.strip
        next if str.nil?

        lesson = {}
        lesson[:time] = slot.css(".time").text.strip
        date_str = slot.css(".date-time").text.strip[0, 6]
        lesson[:date] = Date.parse("#{date_str} #{year}")
        lesson[:ls] = slot.css(".school").text.strip
        lesson[:text] = slot.css(".textbookname").text.strip
        peak ||= peak_times.include?(lesson[:time])
        lesson[:peak] = peak
        lesson[:blue] = slot.classes.include?("client")
        lesson[:related] = slot.classes.include?("related")
        lesson[:booked] = !slot.classes.include?("available")
        lesson[:code] = slot.css(".type").text.strip if lesson[:booked]
        lessons << lesson
      end
    end
    lessons
  end

  def lesson_save(lessons)
    lessons.each { |lesson| @scrape.add_lesson(lesson) }
  end
end
