require 'spec_helper'

describe ChalklerDecorator do
  describe ".provider_links" do
    let(:providers) {[
      FactoryGirl.create(:provider, name: 'Gregs Classes', url_name: 'greg-class', visible: true),
      FactoryGirl.create(:provider, name: 'Local', url_name: '', visible: true)
    ]}
    let(:chalkler) { 
      FactoryGirl.create(:chalkler, :providers => providers)
    }

    it "links to a local provider" do
      expect(chalkler.decorate.provider_links).to include('Local')
    end

    it "doesn't display hidden providers" do
      chalkler.providers.last.update_attribute :visible, false
      expect(chalkler.decorate.provider_links).not_to include('Local', "providers/#{chalkler.providers.last.id}")
    end
  end
end
