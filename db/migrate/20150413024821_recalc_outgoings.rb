class RecalcOutgoings < ActiveRecord::Migration
  def up
    OutgoingPayment.all.each do |payment| 
      unless payment.status == 'not_valid'
        payment.recalculate! include_paid: true
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
