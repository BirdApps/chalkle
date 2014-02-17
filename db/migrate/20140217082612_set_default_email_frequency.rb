class SetDefaultEmailFrequency < ActiveRecord::Migration
  class Chalkler < ActiveRecord::Base
  end

  def up
    change_column_default :chalklers, :email_frequency, 'weekly'
    Chalkler.where(email_frequency: nil).update_all(email_frequency: 'weekly')
  end

  def down
    change_column_default :chalklers, :email_frequency, nil
  end
end
