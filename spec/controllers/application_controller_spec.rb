require "spec_helper"

describe ApplicationController do

  controller do
    def after_sign_in_path_for(resource)
      super
    end
  end

  describe "#region_name" do 
    context "Region is auto detected" do 
      let(:user) { FactoryGirl.build(:user) }
      let(:region) { FactoryGirl.build(:region) }

      it "sets the correct region when region is passed in as params" do 
        params[:region] = region.name
        expect(conroller.region_name).to eq(region)
      end

      it "falls back when the API is down" do
        pending
      end

      it "does not do an API request when supplied with a region param" do 
        pending
      end

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

      let(:user)       { FactoryGirl.build(:chalkler) }
      let(:data_collection) { double("data_collection", path: "/data_collection/fix") }

      before { Chalkler::DataCollection.stub(:new) { data_collection } }

      it "creates a new Chalkler data collector" do
        Chalkler::DataCollection.should_receive(:new)
        controller.after_sign_in_path_for(user)
      end

      it "gets a path name from the Chalkler data collector" do
        data_collection.should_receive(:path)
        controller.after_sign_in_path_for(user)
      end

      it "returns a path based on the resource" do
        expect(controller.after_sign_in_path_for(user)).to eq("/")
      end
    end

  end

end



