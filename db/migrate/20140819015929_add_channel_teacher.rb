class AddChannelTeacher < ActiveRecord::Migration
  def up
    #create table for channel_teachers
    create_table :channel_teachers do |t|
      t.integer :channel_id, null: false
      t.integer :chalkler_id, null: true
      t.string :name, :bio, :pseudo_chalkler_email
      t.boolean :can_make_classes, default: false
    end
    add_foreign_key :channel_teachers, :channels
    add_foreign_key :channel_teachers, :chalklers

    ChannelTeacher.reset_column_information

    new_chalklers = Array.new

    ChannelAdmin.all.each do |channel_admin|
      next if channel_admin.admin_user.nil?
  
      #ensure a chalkler exists with the same email as the channel admin
      chalkler = Chalkler.where("LOWER(chalklers.email) = LOWER('#{channel_admin.admin_user.email}')" ).first

      if chalkler.nil?
        password = SecureRandom.hex(8)
        params = { name: channel_admin.admin_user.name, email: channel_admin.admin_user.email, password: password }  
        Chalkler.observers.disable :all do
          chalkler = Chalkler.create! params
        end
        new_chalklers << params
      end

      #create a channel_teacher using that chalkler
      ChannelTeacher.create channel: channel_admin.channel, chalkler: chalkler, name: chalkler.name

      #associate the chalkler with the channel_admin
      channel_admin.chalkler_id = chalkler.id
      channel_admin.save
    end

    #perhaps contact these people to tell them they are now chalklers aswell...
    puts "------------- START NEW CHALKLERS -------------"
    puts new_chalklers
    puts "------------- END NEW CHALKLERS ---------------"

    #find everyone who has ever taught a class and ensure they are a teacher on that channel
    Course.all.each do |course|
      if ChannelTeacher.select( chalkler_id: course.teacher_id, channel: course.channel).nil?
        chalkler = Chalkler.find course.teacher_id
        ChannelTeacher.create channel: course.channel, chalkler: chalkler, name: chalkler.name
      end
    end
  end

  def down
    drop_table :channel_teachers
  end
end
