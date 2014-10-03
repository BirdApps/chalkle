# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
# Create some channel plans
if ChannelPlan.all.empty?
  community_plan = ChannelPlan.create(name: 'Community', max_channel_admins: 1,max_free_class_attendees: 20, class_attendee_cost: 2, course_attendee_cost: 6, annual_cost: 0, processing_fee_percent: 0.04, max_teachers: 1 )
  ChannelPlan.create(name: 'Standard',max_channel_admins: 2,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10,annual_cost: 0,processing_fee_percent: 0.04, max_teachers: 10 )
  ChannelPlan.create( name: 'Enterprise',max_channel_admins: 2, max_teachers: 10, max_free_class_attendees: nil,class_attendee_cost: 4,course_attendee_cost: 10, annual_cost: 3000,processing_fee_percent: 0.04 )
  ChannelPlan.all.each do |channel_plan|
    puts 'Channel plan created: #{channel_plan.name}'
  end
end

# Create some Channels
if Channel.find_by_name('Enspiral').blank?
  [
    { name: 'Enspiral',
      url_name: "enspiral",
      email: "enspiral@chalkle.com" },
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
end

# Create some Chalklers
if Chalkler.all.empty?
  chalkler = Chalkler.create({name: 'Chalky Chalkler', email: 'chalkler@example.com', password: 'password', name: 'Julie User'}, as: :admin)
  puts "Created chalkler: #{chalkler.name}"

  super_admin = AdminUser.create({name: 'Andy Admin', email: 'super_admin@enspiral.com', password: 'password', role: 'super'}, as: :admin)
  puts "Created Super AdminUser: #{super_admin.name}"

  channel_admin = AdminUser.create({name: 'Channy Channeler', email: 'channel_admin@enspiral.com', password: 'password', role: 'channel admin'}, as: :admin)
  puts "Created AdminUser: #{channel_admin.name}"
end

# Create some categories
if Category.all.empty?
  Category.create([{name: 'one'}, {name: 'two'}, {name: 'three'}], as: :admin)
  Category.all.map {|category| puts "Category Created: #{category.name}"}
end

if Course.all.empty?
#Create some lessons
  courses = Course.create([{name: 'Lesson 1'}, {name: 'Lesson 2'}, {name: 'Lesson 3'}], as: :admin)
  courses.each {|course| puts "Create course: #{course.name}"}

  courses.each do |l|
   l.category = Category.all[rand(0..Category.all.count-1)]
   l.save
   puts "Set category for #{l.name} to: #{l.category.name}"
  end

  channel_admin.channels << Channel.find_by_name("Enspiral")
  puts "Channel Admin \"#{channel_admin.name}\" belongs to channel: #{channel_admin.channels.name}"
end

#make some regions
if Region.all.empty?
  %w{Northland Thames\ Valley Waikato Bay\ of\ Plenty Tongariro East\ Cape Hawkes\ Bay Taranaki Whanganui Wairarapa Manawatu Horowhenua Nelson\ Bays Marlborough Canterbury West\ Coast Central\ Otago Southland}.each do|region_name|
    region = Region.create name: region_name
    puts "Create region: #{region.name}"
  end
end