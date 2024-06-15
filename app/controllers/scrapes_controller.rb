class ScrapesController < ApplicationController
  def new
    raise
  end

  def create
    mechanize
  end

  private

  def mechanize
    mechanize = Mechanize.new
    login_form = mechanize.get("https://mgi.gaba.jp/gis/login/login?form").form
    login_form.username = params[:scrape][:user_id]
    login_form.password = params[:scrape][:password]
    mechanize.submit(login_form, login_form.buttons.first)
    raise
  end
end
