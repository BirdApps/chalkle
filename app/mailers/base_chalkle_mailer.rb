# encoding: UTF-8
class BaseChalkleMailer < ActionMailer::Base
  helper CourseHelper #TODO fix the total weirdness of having the course helper here. Some kind of date lib probably needed


end