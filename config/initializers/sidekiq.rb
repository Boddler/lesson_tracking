require "sidekiq/cron/job"

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

Sidekiq::Cron::Job.create(
  name: "AutoCheck - every hour at 13 minutes past",
  cron: "13 * * * *",
  class: "AutoCheckJob",
)