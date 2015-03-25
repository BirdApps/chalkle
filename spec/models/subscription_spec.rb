require 'spec_helper'

describe Subscription do
  it { should belong_to(:provider) }
  it { should belong_to(:chalkler) }
end
