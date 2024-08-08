class PagesController < ApplicationController
  def home
    @pull = Pull.new
    @pull.save
  end

  def about
  end
end
