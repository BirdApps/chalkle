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
        allow(chalkler).to receive(:update_attributes).and_return(true)
        form = Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email)
        expect(Chalkler).to receive(:where).with("LOWER(email) = LOWER(?)", email) { [] }
        form.save
      end
    end

    context "when saving" do
      it "returns true if the data is persisted" do
        allow(chalkler).to receive(:update_attributes).and_return( true )
        expect(form.save).to be true
      end

      it "returns false if the data is not persisted" do
        allow(chalkler).to receive(:update_attributes).and_return( false )
        expect(form.save).to be false
      end

    end

    context "sending to other objects" do
      it "saves the changes to the Chalkler" do
        expect(chalkler).to receive(:update_attributes) { true }
        form.save
      end

      it "wont overwrite another email address" do
        allow(chalkler).to receive(:email).and_return( "old@address.com" )
        expect(chalkler).not_to receive(:update_attributes)
        form.save
      end
    end
  end

  describe "#persisted?" do
    it "returns false" do
      form = Chalkler::DataCollection::EmailForm.new
      expect(form.persisted?).to be false
    end
  end
end
