# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
# Create some provider plans
if ProviderPlan.all.empty?
  community_plan = ProviderPlan.create(name: 'Community', max_provider_admins: 1,max_free_class_attendees: 20, class_attendee_cost: 2, course_attendee_cost: 6, annual_cost: 0, processing_fee_percent: 0.04, max_teachers: 1 )
  ProviderPlan.create(name: 'Standard',max_provider_admins: 2,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10,annual_cost: 0,processing_fee_percent: 0.04, max_teachers: 10 )
  ProviderPlan.create( name: 'Enterprise',max_provider_admins: 2, max_teachers: 10, max_free_class_attendees: nil,class_attendee_cost: 4,course_attendee_cost: 10, annual_cost: 3000,processing_fee_percent: 0.04 )
  ProviderPlan.all.each do |provider_plan|
    puts 'Provider plan created: #{provider_plan.name}'
  end
end

# Create some Providers
if Provider.find_by_name('Enspiral').blank?
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
  ].each do |provider_attrs|
    provider = Provider.new
    provider_attrs.map {|name, value| provider.update_attribute name, value } 
    provider.save
    puts "Provider Created: #{provider.name}"
  end
end

# Create some Chalklers
if Chalkler.all.empty?
  chalkler = Chalkler.create({name: 'Chalky Chalkler', email: 'chalkler@example.com', password: 'password', name: 'Julie User'}, as: :admin)
  puts "Created chalkler: #{chalkler.name}"

end

if Course.all.empty?
#Create some lessons
  courses = Course.create([{name: 'Lesson 1'}, {name: 'Lesson 2'}, {name: 'Lesson 3'}], as: :admin)
  courses.each {|course| puts "Create course: #{course.name}"}

  provider_admin.providers << Provider.find_by_name("Enspiral")
  puts "Provider Admin \"#{provider_admin.name}\" belongs to provider: #{provider_admin.providers.name}"
end

