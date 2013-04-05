class ChannelDecorator < Draper::Decorator
  delegate_all

  def turnover_table(last_day, period, num_rows)
    turnover = []
    (0..(num_rows-1)).each do |i|
      turnover[i] = financial_stats(last_day.weeks_ago(i+1),period).turnover
   	end
   	turnover  
  end

  def cost_table(last_day, period, num_rows)
    cost = []
    (0..(num_rows-1)).each do |i|
      cost[i] = financial_stats(last_day.weeks_ago(i+1),period).cost
   	end
   	cost  
  end

  def attendee_table(last_day, period, num_rows)
    attendee = []
    (0..(num_rows-1)).each do |i|
      attendee[i] = lesson_stats(last_day.weeks_ago(i+1),period).attendee
    end
    attendee
  end

  def fill_fraction_table(last_day, period, num_rows)
    fill_fraction = []
    (0..(num_rows-1)).each do |i|
      fill_fraction[i] = lesson_stats(last_day.weeks_ago(i+1),period).fill_fraction
    end
    fill_fraction
  end

  def new_chalklers_table(last_day, period, num_rows)
    new_chalklers = []
    (0..(num_rows-1)).each do |i|
      new_chalklers[i] = chalkler_stats(last_day.weeks_ago(i+1),period).new_chalklers
    end
    new_chalklers
  end

  def percent_active_table(last_day, period, num_rows)
    percent_active = []
    (0..(num_rows-1)).each do |i|
      percent_active[i] = chalkler_stats(last_day.weeks_ago(i+1),period).percent_active
    end
    percent_active
  end

  def lessons_ran_table(last_day, period, num_rows)
    lessons_ran = []
    (0..(num_rows-1)).each do |i|
      lessons_ran[i] = lesson_stats(last_day.weeks_ago(i+1),period).lessons_ran
    end
    lessons_ran
  end

  def new_lessons_ran_table(last_day, period, num_rows)
    new_lessons_ran = []
    (0..(num_rows-1)).each do |i|
      new_lessons_ran[i] = lesson_stats(last_day.weeks_ago(i+1),period).new_lessons_ran
    end
    new_lessons_ran
  end

  def cancelled_lessons_table(last_day, period, num_rows)
    cancelled_lessons = []
    (0..(num_rows-1)).each do |i|
      cancelled_lessons[i] = lesson_stats(last_day.weeks_ago(i+1),period).cancelled_lessons
    end
    cancelled_lessons
  end

  def new_cancelled_lessons_table(last_day, period, num_rows)
    new_cancelled_lessons = []
    (0..(num_rows-1)).each do |i|
      new_cancelled_lessons[i] = lesson_stats(last_day.weeks_ago(i+1),period).new_cancelled_lessons
    end
    new_cancelled_lessons
  end

  def paid_lessons_table(last_day, period, num_rows)
    paid_lessons = []
    (0..(num_rows-1)).each do |i|
      paid_lessons[i] = lesson_stats(last_day.weeks_ago(i+1),period).paid_lessons
    end
    paid_lessons
  end

end