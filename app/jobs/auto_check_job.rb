class AutoCheckJob
  include Sidekiq::Worker

  def perform(*args)
    # Log the message to Sidekiq logs
    Sidekiq.logger.info "Running AutoCheckJob"
  end
end
