require 'spec_helper'

describe AdminUser do
  it { should have_many(:groups).through(:group_admins) }
end
