require 'spec_helper'

describe ChannelAdmin do
  it { should belong_to(:channel) }
  it { should belong_to(:admin_user) }
end
