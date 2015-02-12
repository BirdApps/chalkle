require 'spec_helper'

describe ProviderCategory do
  it { should belong_to(:provider) }
  it { should belong_to(:category) }
end
