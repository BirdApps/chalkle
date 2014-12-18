class Sudo::BaseController < ApplicationController
  before_filter :authorize_super
  before_filter :set_titles

  def set_titles
    @page_title_logo = 'http://i.imgur.com/Y4kT12T.jpg'
    @page_title = "Chalkle Admin"
    @page_subtitle = "Sudo"
    controller_parts = request.path_parameters[:controller].split("/")
    action_parts = request.path_parameters[:action].split("/")
    @page_context_links = [
      {
        img_name: "metrics",
        link: sudo_metrics_path,
        active: controller_parts.include?("metrics"),
        title: "Metrics"
      },
      {
        img_name: "bolt",
        link: sudo_bookings_path,
        active: controller_parts.include?("bookings") && !action_parts.include?("pending_refunds") ,
        title: "Bookings"
      },
      {
        img_name: "book",
        link: sudo_outgoing_payments_path,
        active: controller_parts.include?("outgoings"),
        title: "Outgoings"
      },
      {
        img_name: "people",
        link: sudo_chalklers_path,
        active: controller_parts.include?("chalklers"),
        title: "Chalklers"
      },
      {
        img_name: "book",
        link: sudo_partner_inquiries_path,
        active: controller_parts.include?("partner_inquiries"),
        title: "Hello"
      }

    ]
  end

  def authorize_super
    @sudo = Sudo.new
    authorize @sudo
  end

end
