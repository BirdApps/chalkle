require "spec_helper"

describe ProviderContact do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:provider_contact) {
   FactoryGirl.build(:provider_contact) }

  describe "Provider Mailer" do

    it 'should send email' do 
      expect{ provider_contact.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

  end

end
