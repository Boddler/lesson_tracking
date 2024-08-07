class PagesController < ApplicationController
  def home
    @scrape = Scrape.new
    @pull = Pull.new
    @pull.save
  end

  def about
  end
end
