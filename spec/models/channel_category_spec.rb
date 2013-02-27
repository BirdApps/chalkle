require 'spec_helper'

describe ChannelCategory do
  it { should belong_to(:channel) }
  it { should belong_to(:category) }
end
