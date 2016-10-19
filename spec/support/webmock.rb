WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    # this is a heavy hammer indeed. But a practical one.
    stub_request(:post, "https://go.goroost.com/api/push")
  end
end
