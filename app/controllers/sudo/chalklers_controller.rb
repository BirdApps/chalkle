class Sudo::ChalklersController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles

  def become
    sort_params = params[:order] || "name ASC"
    @chalklers = Chalkler.order(sort_params).take(50)


    @signups_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Weekly Signups")
      f.xAxis(:categories => Array.new(30){|i| d = i.weeks.ago.to_date; "#{d.day}/#{d.month}" }.reverse )
      f.series(:name => "Signups", :yAxis => 0, :data => Array.new(30) {|i|
        Chalkler.where('created_at BETWEEN ? AND ?', (i+1).weeks.ago, i.weeks.ago ).count
      }.reverse )

      f.chart({:defaultSeriesType=>"column"})
    end

  end

  def becoming
    return unless current_user.super?
    sign_in(:chalkler, Chalkler.find(params[:id]), { :bypass => true })
    redirect_to root_path
  end
end

