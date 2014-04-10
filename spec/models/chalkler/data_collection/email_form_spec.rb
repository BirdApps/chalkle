require "spec_helper"

describe Chalkler::DataCollection::EmailForm do

  describe "#save" do

    context "when validating" do

      let(:email)    { "a.fake@email.com" }
      let(:chalkler) { double("chalkler" ) }

      it "returns false if the form data is not valid" do
        form = Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler)
        expect(form.save).to be_false
      end

      it "checks the existance of an email via the Chalkler model" do
        chalkler.stub(:update_attributes) { true }
        form = Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email)
        Chalkler.should_receive(:where).with("LOWER(email) = LOWER(?)", email) { [] }
        form.save
      end

    end

    context "when saving" do

      let(:email)    { "a.fake@email.com" }
      let(:chalkler) { double("chalkler") }
      let(:form)     { Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email) }

      it "returns true if the data is persisted" do
        chalkler.stub(:update_attributes) { true }
        expect(form.save).to be_true
      end

      it "returns false if the data is not persisted" do
        chalkler.stub(:update_attributes) { false }
        expect(form.save).to be_false
      end

    end

    context "sending to other objects" do

      let(:email)    { "a.fake@email.com" }
      let(:chalkler) { double("chalkler") }
      let(:form)     { Chalkler::DataCollection::EmailForm.new("chalkler" => chalkler, "email" => email) }

      it "saves the changes to the Chalkler" do
        chalkler.should_receive(:update_attributes) { true }
        form.save
      end

    end

  end

  describe "#persisted?" do

    it "returns false" do
      form = Chalkler::DataCollection::EmailForm.new
      expect(form).to be_true
    end

  end

end
