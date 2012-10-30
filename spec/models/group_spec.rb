require 'spec_helper'

describe Group do
  it { should validate_presence_of :name }
  it { should validate_presence_of :url_name }
  it { should validate_presence_of :api_key }
end
