require 'spec_helper'

describe ChalklerPreferences do
  let(:chalkler) { double('chalkler', email: 'test@user.com', email_frequency: 'weekly', email_categories: [1]) }

  describe "#initialize" do
    before { @email_prefs = ChalklerPreferences.new(chalkler) }

    it "extracts an email" do
      @email_prefs.email.should eq('test@user.com')
    end

    it "extracts an email_frequency" do
      @email_prefs.email_frequency.should eq('weekly')
    end

    it "extracts the eamil categories" do
      @email_prefs.email_categories.should eq([1])
    end
  end
end
