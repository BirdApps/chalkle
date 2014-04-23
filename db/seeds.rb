# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
# Create some cities
  %w(Chicago Copenhagen).each do |city_name|
    city = City.new
    city.name = city_name
    city.save
    puts "City created: #{city.name}"
  end

# Create some Channels
[
  { name: 'Wellington',
    url_name: "sixdegrees",
    email: "wellington@chalkle.com" },
  { name: 'Horowhenua',
    url_name: "horowhenua",
    email: "horowhenua@chalkle.com" },
  { name: 'Wellington Whānau',
    url_name: "whanau",
    email: "whanau@chalkle.com" }
].each do |channel_attrs|
  channel = Channel.new
  channel_attrs.map {|name, value| channel.update_attribute name, value } 
  channel.save
  puts "Channel Created: #{channel.name}"
end

# Create some Chalklers

chalkler = Chalkler.create({name: 'Chalky Chalkler', email: 'chalkler@example.com', password: 'password', name: 'Julie User'}, as: :admin)
puts "Created chalkler: #{chalkler.name}"

super_admin = AdminUser.create({name: 'Andy Admin', email: 'super_admin@enspiral.com', password: 'password', role: 'super'}, as: :admin)
puts "Created Super Admin: #{super_admin.name}"


channel_admin = AdminUser.create({name: 'Channy Channeler', email: 'channel_admin@enspiral.com', password: 'password', role: 'channel admin'}, as: :admin)
puts "Created channel Admin: #{channel_admin.name}"

# Create some categories
Category.create([{name: 'one'}, {name: 'two'}, {name: 'three'}], as: :admin)
Category.all.map {|category| puts "Category Created: #{category.name}"}

#Create some lessons
lessons = Lesson.create([{name: 'Lesson 1'}, {name: 'Lesson 2'}, {name: 'Lesson 3'}], as: :admin)
lessons.each {|lesson| puts "Create Lesson: #{lesson.name}"}

lessons.each do |l|
 l.category = Category.all[rand(0..Category.all.count-1)]
 l.save
 puts "Set category for #{l.name} to: #{l.category.name}"
end

channel_admin.channels << Channel.find_by_name("Wellington")
puts "Channel Admin \"#{channel_admin.name}\" belongs to channel: #{channel_admin.channels.name}"


#make some regions
%w{Northland Thames\ Valley Waikato Bay\ of\ Plenty Tongariro East\ Cape Hawkes\ Bay Taranaki Whanganui Wairarapa Manawatu Horowhenua Nelson\ Bays Marlborough Canterbury West\ Coast Central\ Otago Southland}.each do|region_name|
  region = Region.create name: region_name
  puts "Create region: #{region.name}"
end