require "spec_helper"

describe ApplicationController do

  controller do
    def after_sign_in_path_for(resource)
      super
    end
  end

  describe "#after_sign_in_path_for" do

    context "when an Admin User signs in successfully" do

      let(:user) { FactoryGirl.build(:admin_user) }

      it "returns the admin root url" do
        expect(controller.after_sign_in_path_for(user)).to eq("/admin")
      end

    end

    context "when a Chalkler signs in successfully" do

      let(:user)       { FactoryGirl.build(:chalkler) }
      let(:validation) { double("validation", path_name: "/validation/fix") }

      before { ChalklerValidation.stub(:new) { validation } }

      it "creates a new Chalkler validator" do
        ChalklerValidation.should_receive(:new)
        controller.after_sign_in_path_for(user)
      end

      it "gets a path name from the Chalkler validator" do
        validation.should_receive(:path_name)
        controller.after_sign_in_path_for(user)
      end

      it "returns a path based on the resource" do
        expect(controller.after_sign_in_path_for(user)).to eq("/validation/fix")
      end

    end

  end

end



