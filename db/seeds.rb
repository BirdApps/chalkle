# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
wellington = Channel.create(name: 'Wellington', url_name: 'sixdegrees', email: 'wellington@chalkle.com')
whanau = Channel.create(name: 'Wellington Whānau', url_name: 'whanau', email: 'whanau@chalkle.com')
horowhenua = Channel.create(name: 'Horowhenua', url_name: 'horowhenua', email: 'horowhenua@chalkle.com')

chalkler = Chalkler.create(email: 'chalkler@example.com', password: 'password', name: 'Julie User')
super_admin = AdminUser.create(email: 'super_admin@enspiral.com', password: 'password', role: 'super')
channel_admin = AdminUser.create(email: 'channel_admin@enspiral.com', password: 'password', role: 'channel admin')

Category.create([{name: 'one'}, {name: 'two'}, {name: 'three'}])
lessons = Lesson.create([{name: 'Lesson 1'}, {name: 'Lesson2'}, {name: 'Lesson3'}])

lessons.each do |l|
  l.categories << Category.first
end
channel_admin.channels << wellington
