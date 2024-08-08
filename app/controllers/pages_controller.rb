class PagesController < ApplicationController
  def home
    @scrape = Scrape.new
  end

  def about
  end
end
