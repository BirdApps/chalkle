require 'spec_helper'

describe GroupCategory do
  it { should belong_to(:group) }
  it { should belong_to(:category) }
end
