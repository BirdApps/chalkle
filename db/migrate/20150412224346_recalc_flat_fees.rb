class RecalcFlatFees < ActiveRecord::Migration
  def up
    courses = Course.where(teacher_pay_type: Course.teacher_pay_types[0])
    puts courses.map { |c| c.teacher_payment.recalculate!(true) if c.teacher_payment.present? }
    puts courses.map { |c| c.provider_payment.recalculate!(true) if c.provider_payment.present? }
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
