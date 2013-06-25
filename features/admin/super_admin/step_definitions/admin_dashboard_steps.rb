Given(/^there is a paid class coming up$/) do
  FactoryGirl.create(:lesson, name: "Test class", cost: 10, status: "Published", start_at: 2.days.from_now, min_attendee: 10)
end

Given(/^there is an unpaid booking for this class$/) do
  chalkler = FactoryGirl.create(:chalkler, name: "Test chalkler")
  lesson = Lesson.find_by_name("Test class")
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, paid: false)
end

Given(/^there is a paid class tomorrow$/) do
  FactoryGirl.create(:lesson, name: "Test class", cost: 10, status: "Published", start_at: 1.day.from_now)
end

Given(/^there was a paid class yesterday$/) do
  teacher = FactoryGirl.create(:chalkler, name: "Test chalkler")
  lesson = FactoryGirl.create(:lesson, name: "Test class", teacher_cost: 5, cost: 10, status: "Published", start_at: 1.day.ago, teacher_id: teacher.id)
end

