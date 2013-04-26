ActiveAdmin.register_page "Performance" do

  controller do
    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
    end
  end

  content do
    panel "Channel performance" do
      num_weeks = 5
      render partial: "/admin/performance/performance", locals: {channels: Channel.accessible_by(current_ability).where("url_name <> ''"), num_weeks: num_weeks, period: 1.week}
    end
  end

end
