require "spec_helper"

describe Chalkler::DataCollection::EmailForm do
  let(:email)    { "a.fake@email.com" }
  let(:chalkler) { double("chalkler", email: nil) }
  let(:form)     { Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email) }

  describe "#save" do
    context "when validating" do
      it "returns false if the form data is not valid" do
        form = Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler)
        expect(form.save).to be false
      end

      it "checks the existance of an email via the Chalkler model" do
        chalkler.stub(:update_attributes) { true }
        form = Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email)
        expect(Chalkler).to receive(:where).with("LOWER(email) = LOWER(?)", email) { [] }
        form.save
      end
    end

    context "when saving" do
      it "returns true if the data is persisted" do
        chalkler.stub(:update_attributes) { true }
        expect(form.save).to be true
      end

      it "returns false if the data is not persisted" do
        chalkler.stub(:update_attributes) { false }
        expect(form.save).to be false
      end

    end

    context "sending to other objects" do
      it "saves the changes to the Chalkler" do
        chalkler.should_receive(:update_attributes) { true }
        form.save
      end

      it "wont overwrite another email address" do
        chalkler.stub(:email) { "old@address.com" }
        chalkler.should_receive(:update_attributes).never
        form.save
      end
    end
  end

end
