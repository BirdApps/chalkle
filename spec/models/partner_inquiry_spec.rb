require 'spec_helper'

describe PartnerInquiry do
  let(:partner_inquiry) { FactoryGirl.create(:partner_inquiry) }
  
  it 'should have a name' do 
    expect(partner_inquiry.name).not_to be_nil
  end

end
