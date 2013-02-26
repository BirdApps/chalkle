require 'spec_helper'

describe ChannelChalkler do
  it { should belong_to(:channel) }
  it { should belong_to(:chalkler) }
end
