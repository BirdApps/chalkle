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
      let(:data_collection) { double("data_collection", path_name: "/data_collection/fix") }

      before { Chalkler::DataCollection.stub(:new) { data_collection } }

      it "creates a new Chalkler data collector" do
        Chalkler::DataCollection.should_receive(:new)
        controller.after_sign_in_path_for(user)
      end

      it "gets a path name from the Chalkler data collector" do
        data_collection.should_receive(:path_name)
        controller.after_sign_in_path_for(user)
      end

      it "returns a path based on the resource" do
        expect(controller.after_sign_in_path_for(user)).to eq("/data_collection/fix")
      end

    end

  end

end



