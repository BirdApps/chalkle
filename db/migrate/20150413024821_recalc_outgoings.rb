class RecalcOutgoings < ActiveRecord::Migration
  def up
    OutgoingPayment.all.each do |payment| 
      payment.recalculate! include_paid: true
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
