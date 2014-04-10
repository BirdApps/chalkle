require "spec_helper"

describe Chalklers::DataCollectionFormController do

  login_chalkler

  describe "#email" do
    it "creates an email form object" do
      Chalkler::DataCollection::EmailForm.should_receive(:new)
      get :email
    end

    it "renders the email template" do
      get :email
      expect(response).to render_template("chalklers/data_collection_form/email")
    end
  end

  describe "#update_email" do

    let(:form)      { double("form", save: true) }
    let(:form_args) { { chalkler_data_collection_email_form: { email: "test@example.com" } } }

    before { form.stub_chain(:errors, :full_messages) { [] } }

    it "creates an email form object" do
      Chalkler::DataCollection::EmailForm.should_receive(:new) { form }
      post :update_email, form_args
    end

    it "redirects to the chalkler root path if successful" do
      Chalkler::DataCollection::EmailForm.stub(:new) { form }
      post :update_email, form_args
      expect(response).to redirect_to(chalklers_root_url)
    end

    it "renders the email form if unsuccessful" do
      form.stub(:save) { false }
      Chalkler::DataCollection::EmailForm.stub(:new) { form }
      post :update_email, form_args
      expect(response).to render_template("chalklers/data_collection_form/email")
    end
  end

end

