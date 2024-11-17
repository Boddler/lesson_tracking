class OtherController < ApplicationController
  def job_done
  end

  def welcome
  end

  def trigger_job
    HelloWorldJob.perform_later
    redirect_to other_job_done_path
  end

  def index
  end
end
