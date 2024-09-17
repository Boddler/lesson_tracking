class AutoCheckJob
  include Sidekiq::Worker

  def perform(*args)
    Sidekiq.logger.info "Running AutoCheckJob"
  end
end
