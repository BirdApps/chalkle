class People::DataCollectionFormController < ApplicationController

  before_filter :authenticate_chalkler!

  def email
    render_email_form
  end

  def update_email
    form = Chalkler::DataCollection::EmailForm.new(form_data)
    form.save ? successful_update(form) : failed_update(form)
  end

private

  def form_data
    data = params.fetch("chalkler_data_collection_email_form", {})
    data.merge({ "chalkler" => current_chalkler })
  end

  def successful_update(form)
    flash[:notice] = "Everything has been successfully updated."
    redirect_to root_url
  end

  def failed_update(form)
    flash[:alert] = "Oops, there was an issue: #{formatted_error_messages(form)}"
    render_email_form
  end

  def render_email_form
    render "email", locals: {
      form_object: Chalkler::DataCollection::EmailForm.new(form_data),
      submit_path: chalklers_data_collection_update_path(action: "update_email")
    }
  end

  def formatted_error_messages(form)
    form.errors.full_messages.join(", ")
  end

end
