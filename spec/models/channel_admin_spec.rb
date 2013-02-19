require 'spec_helper'

describe GroupAdmin do
  it { should belong_to(:group) }
  it { should belong_to(:admin_user) }
end
