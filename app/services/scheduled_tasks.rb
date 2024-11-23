class ScheduledTasks
  include ApplicationHelper
  def initialize
    @pull = Pull.new

  end
end
