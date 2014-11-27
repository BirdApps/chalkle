class Notifier
  after_filter :notify
    binding.pry
  def notify
    binding.pry
  end
end

ActiveSupport.on_load(:action_controller) do
  include Notifier
  binding.pry
end