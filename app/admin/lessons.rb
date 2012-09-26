ActiveAdmin.register Lesson, as: 'Class' do

  index do
    column :id
    column :title
    column :category
    column :teacher
    column :cost
    column :charge
    column :start
    column :end
    default_actions
  end
  
end
