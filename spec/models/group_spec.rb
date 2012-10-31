require 'spec_helper'

describe Group do
  it { should have_many(:admin_users).through(:group_admins) }
  it { should have_many(:chalklers).through(:group_chalklers) }
  it { should have_many(:lessons).through(:group_lessons) }
  it { should have_many(:bookings).through(:lessons) }
  it { should have_many(:categories).through(:group_categories) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url_name }
  it { should validate_presence_of :api_key }
end
