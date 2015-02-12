class AddProviderTeacher < ActiveRecord::Migration
  def up
    #create table for provider_teachers
    create_table :provider_teachers do |t|
      t.integer :provider_id, null: false
      t.integer :chalkler_id, null: true
      t.string :name, :bio, :pseudo_chalkler_email
      t.boolean :can_make_classes, default: false
    end
    add_foreign_key :provider_teachers, :providers
    add_foreign_key :provider_teachers, :chalklers

    ProviderTeacher.reset_column_information

    new_chalklers = Array.new

    ProviderAdmin.all.each do |provider_admin|
      next if provider_admin.admin_user.nil?
  
      #ensure a chalkler exists with the same email as the provider admin
      chalkler = Chalkler.where("LOWER(chalklers.email) = LOWER('#{provider_admin.admin_user.email}')" ).first

      if chalkler.nil?
        password = SecureRandom.hex(8)
        params = { name: provider_admin.admin_user.name, email: provider_admin.admin_user.email, password: password }  
        Chalkler.observers.disable :all do
          chalkler = Chalkler.create! params
        end
        new_chalklers << params
      end

      #create a provider_teacher using that chalkler
      ProviderTeacher.create provider: provider_admin.provider, chalkler: chalkler, name: chalkler.name

      #associate the chalkler with the provider_admin
      provider_admin.chalkler_id = chalkler.id
      provider_admin.save
    end

    #perhaps contact these people to tell them they are now chalklers aswell...
    puts "------------- START NEW CHALKLERS -------------"
    puts new_chalklers
    puts "------------- END NEW CHALKLERS ---------------"

    #find everyone who has ever taught a class and ensure they are a teacher on that provider
    Course.all.each do |course|
      if ProviderTeacher.select( chalkler_id: course.teacher_id, provider: course.provider).nil?
        chalkler = Chalkler.find course.teacher_id
        ProviderTeacher.create provider: course.provider, chalkler: chalkler, name: chalkler.name
      end
    end
  end

  def down
    drop_table :provider_teachers
  end
end
