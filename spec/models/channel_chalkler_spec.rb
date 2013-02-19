require 'spec_helper'

describe GroupChalkler do
  it { should belong_to(:group) }
  it { should belong_to(:chalkler) }
end
