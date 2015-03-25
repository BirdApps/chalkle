require "spec_helper"

describe ApplicationController do

  controller do
    def after_sign_in_path_for(resource)
      super
    end
  end

  describe "#after_sign_in_path_for" do

    context "when an Admin User signs in successfully" do

      let(:user) { FactoryGirl.build(:admin_chalkler) }

      it "returns the admin root url" do
        expect(controller.after_sign_in_path_for(user)).to eq("/")
      end

    end

    context "when a Chalkler signs in successfully" do

      let(:user) { FactoryGirl.build(:chalkler) }

      it "returns a path based on the resource" do
        expect(controller.after_sign_in_path_for(user)).to eq("/")
      end
    end

  end

end



