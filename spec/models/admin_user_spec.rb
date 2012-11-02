require 'spec_helper'

describe AdminUser do
  it { should have_many(:groups).through(:group_admins) }
  it { should have_many(:lessons).through(:groups) }
  it { should have_many(:chalklers).through(:groups) }
  it { should have_many(:bookings).through(:groups) }
  it { should have_many(:categories).through(:groups) }
  it { should have_many(:payments).through(:bookings) }
end
