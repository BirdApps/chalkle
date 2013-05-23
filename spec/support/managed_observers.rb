module ManagedObservers
  def with_observer(*observers)
    ActiveRecord::Base.observers.enable(*observers)
    yield
    ActiveRecord::Base.observers.disable(:all)
  end

  alias_method :with_observers, :with_observer
end

RSpec.configure do |config|
  config.include ManagedObservers

  config.before(:all) do
    ActiveRecord::Base.observers.disable(:all)
  end
end