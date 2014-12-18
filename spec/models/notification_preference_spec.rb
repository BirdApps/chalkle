require 'spec_helper'

describe NotificationPreference do
  let(:notification_preference) { FactoryGirl.create :notification_preference }
  
  let(:first_option){ NotificationPreference::ALL_NOTIFICATIONS.first }
  
  describe "dynamically generates methods for each notification option" do
    NotificationPreference::ALL_NOTIFICATIONS.each do |option|
      it "should have read method for option: #{option}" do
        expect( notification_preference.send(option) ).to be true
      end
    end
  end

  describe "persistance" do
    it "can update preferences" do
      pref_copy = notification_preference.preferences.clone
      pref_copy[first_option] = false
      notification_preference.preferences = pref_copy
      expect( notification_preference.send(first_option) ).to be false
    end
  end

  describe "forward compatibility" do
    it "should return true when the key is not present but it is a defined method" do
      notification_preference.preferences = notification_preference.preferences.except(first_option)
     expect( notification_preference.send(first_option) ).to be true
    end
  end

end