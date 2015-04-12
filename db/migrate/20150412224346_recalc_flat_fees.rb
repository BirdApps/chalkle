class RecalcFlatFees < ActiveRecord::Migration
  def up
    courses = Course.where(teacher_pay_type: Course.teacher_pay_types[0])
    courses.map { |c| c.teacher_payment.recalculate!(true) if c.teacher_payment }
    courses.map { |c| c.provider_payment.recalculate!(true) if c.provider_payment }
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
