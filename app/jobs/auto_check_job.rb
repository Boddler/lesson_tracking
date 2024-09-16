class AutoCheckJob
  include Sidekiq::Worker

  def perform(*args)
    # The task to run at 55 minutes past the hour
    puts "Running AutoCheckJob"
  end
end
