require 'spec_helper'

describe Lesson do
  it { should validate_uniqueness_of :meetup_id }
end
