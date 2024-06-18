class ScrapesController < ApplicationController
  def create
    log_in
    info_pull
  end

  private

  def log_in
    @mechanize = Mechanize.new
    login_form = @mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form
    login_form.username = params[:scrape][:user_id]
    login_form.password = params[:scrape][:password]
    @mechanize.submit(login_form, login_form.buttons.first)
  end

  def info_pull
    raise
  end
end
