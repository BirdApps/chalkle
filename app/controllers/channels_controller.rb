class ChannelsController < ApplicationController
  def horowhenua
    @lessons = Lesson.joins{ channels }.visible.published.where{ (channels.name == 'Horowhenua') & (lessons.start_at > Time.now.utc) }.order("start_at").decorate
  end
end