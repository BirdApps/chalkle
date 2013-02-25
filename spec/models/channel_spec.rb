require 'spec_helper'

describe Channel do
  it { should have_many(:admin_users).through(:channel_admins) }
  it { should have_many(:chalklers).through(:channel_chalklers) }
  it { should have_many(:lessons).through(:channel_lessons) }
  it { should have_many(:bookings).through(:lessons) }
  it { should have_many(:categories).through(:channel_categories) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url_name }
end
