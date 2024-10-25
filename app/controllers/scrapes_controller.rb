class ScrapesController < ApplicationController
  def create
    # log in to the site
    submission = log_in
    @pull = Pull.find(params[:pull_id])
    # check if logged in
    @date = Date.today.months_ago(1)
    main_page = @mechanize.get("https://mgi.gaba.jp/gis/view_schedule-ls/list?jp.co.gaba.targetUserStore=")
    monthly_view = @mechanize.click(main_page.at(".day-desc a"))
    if submission.links[0].text == "INSTRUCTOR PROFILE"
      @scrape = start
      past = info_pull_past(monthly_view)
      @scrape = start
      current = info_pull_current(monthly_view)
      @scrape = start
      future = info_pull_future(monthly_view)
      all = past + current + future
      lesson_save(all)
      @scrape.lesson_count(@date)
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

  def month_cut(lessons)
    # don't think we need this now
    lessons.select { |lesson| lesson[:date].month == @date.month }
  end

  def start
    yyyymm = "#{@date.year}#{"0" if @date.month < 10}#{@date.month}".to_i
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

  def info_pull_current(monthly_view)
    lessons = []
    parsed_data = weekly_parse(monthly_view)
    lessons.concat(parsed_data) if parsed_data.is_a?(Array)
    @scrape.lesson_count(@date)
    @date = @date.next_month
    lessons
  end

  def info_pull_past(monthly_view)
    lessons = []
    month = @mechanize.click(monthly_view.at("a.pull-left"))
    parsed_data = weekly_parse(month)
    lessons.concat(parsed_data) if parsed_data.is_a?(Array)
    @scrape.lesson_count(@date)
    @date = @date.next_month
    lessons
  end

  def info_pull_future(monthly_view)
    lessons = []
    month = @mechanize.click(monthly_view.at("a.pull-right"))
    parsed_data = weekly_parse(month)
    lessons.concat(parsed_data) if parsed_data.is_a?(Array)
    lessons
  end

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

  def lesson_save(lessons)
    lessons.each { |lesson| @scrape.add_lesson(lesson) }
  end

  def log_in
    @mechanize = Mechanize.new
    login_form = @mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form
    login_form.username = params[:user_id]
    login_form.password = params[:password]
    @mechanize.submit(login_form, login_form.buttons.first)
  end
end
