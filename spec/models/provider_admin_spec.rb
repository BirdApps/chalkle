require 'spec_helper'

describe ProviderAdmin do
  it { should belong_to(:provider) }
  it { should belong_to(:chalkler) }
  it { should have_many(:courses) }
end
