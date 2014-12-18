require 'spec_helper'

describe ChannelAdmin do
  it { should belong_to(:channel) }
  it { should belong_to(:chalkler) }
  it { should have_many(:courses) }
end
