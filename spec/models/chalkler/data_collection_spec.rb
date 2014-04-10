require "spec_helper"

describe Chalkler::DataCollection do

  let(:chalkler) { double("chalkler", email: "fake@email.com") }

  describe "#path" do

    context "when no new data needs to be collected" do

      context "when there is an originating path to go back to" do

        it "returns the original path" do
          options = { original_path: "/class/bookings" }
          data_collection = Chalkler::DataCollection.new(chalkler, options)
          expect(data_collection.path).to eq("/class/bookings")
        end

      end

      context "when there isn't a originating path to go back to" do

        it "returns a specified default path" do
          options         = { default_path: "/welcome" }
          data_collection = Chalkler::DataCollection.new(chalkler, options)
          expect(data_collection.path).to eq("/welcome")
        end

        it "returns and empty string if no default path provided" do
          data_collection = Chalkler::DataCollection.new(chalkler)
          expect(data_collection.path).to eq("")
        end

      end

    end

    context "when the an email address is required for the Chalkler" do
      before { chalkler.stub(:email) { nil } }

      it "returns the path to the email form" do
        data_collection = Chalkler::DataCollection.new(chalkler)
        expect(data_collection.path).to eq("/chalklers/data_collection/email")
      end

      it "returns the email form path as well as the encoded original path" do
        options = { original_path: "/class/bookings" }
        data_collection = Chalkler::DataCollection.new(chalkler, options)
        expect(data_collection.path).to eq("/chalklers/data_collection/email?original_path=%2Fclass%2Fbookings")
      end

    end
  end

end
