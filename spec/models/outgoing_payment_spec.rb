require 'spec_helper'

describe OutgoingPayment do
  let(:provider) { FactoryGirl.create(:provider) }
  let(:teacher){ FactoryGirl.create(:provider_teacher, provider: provider )}
  let(:lesson){ FactoryGirl.create(:past_lesson)}
  let(:course) { FactoryGirl.create(:course_with_bookings, provider: provider, teacher: teacher, status: 'Completed', lessons: [lesson])}

  it 'should total no more than the sum of the payments' do
    course.create_outgoing_payments!
   
    teacher_payment = OutgoingPayment.pending_payment_for_teacher(teacher)
    provider_payment = OutgoingPayment.pending_payment_for_teacher(teacher)
    payments_sum = course.payments.sum(&:total)
   
    expect(teacher_payment.total + provider_payment.total).to be <= payments_sum
  end
  
  describe '.pending_payment_for_teacher' do    
    it "should return a new teacher_payment if none are pending" do
      old_count = teacher.outgoing_payments.count
      outgoing = OutgoingPayment.pending_payment_for_teacher(teacher)
      expect(teacher.outgoing_payments.count).to eq(old_count + 1)
    end

    it "should return the pending teacher_payment if one is pending" do
      outgoing1 = OutgoingPayment.pending_payment_for_teacher(teacher)
      outgoing2 = OutgoingPayment.pending_payment_for_teacher(teacher)
      expect(outgoing1).to eq(outgoing2)
    end
  end

  describe '.pending_payment_for_provider' do
    it "should return a new provider_payment if none are pending" do
      old_count = provider.outgoing_payments.count
      outgoing = OutgoingPayment.pending_payment_for_provider(provider)
      expect(provider.outgoing_payments.count).to eq(old_count + 1)
    end

    it "should return the pending provider_payment if one is pending" do
      outgoing1 = OutgoingPayment.pending_payment_for_provider(provider)
      outgoing2 = OutgoingPayment.pending_payment_for_provider(provider)
      expect(outgoing1).to eq(outgoing2)
    end
  end

end