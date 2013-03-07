# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
AdminUser.create(email: 'joshua@enspiral.com', password: 'password', role: 'super')
Chalkler.create(email: 'chalkler@example.com', password: 'password', name: 'Julie User')
Channel.create(name: 'Wellington', url_name: 'sixdegrees')
Channel.create(name: 'Wellington Whaanau', url_name: 'whanau')
