require "spec_helper"

describe ProviderContact do
  let!(:provider_contact) { build(:provider_contact) }

  describe "Provider Mailer" do
    it 'should send email' do
      expect{ provider_contact.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
