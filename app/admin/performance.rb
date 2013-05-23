ActiveAdmin.register_page "Performance" do

  controller do
    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
    end
  end

  content do
    panel "Channel performance" do
      render partial: "/admin/performance/performance", locals: { channels: Channel.visible.accessible_by(current_ability), num_weeks: 5, period: 1.week }
    end
  end

end
