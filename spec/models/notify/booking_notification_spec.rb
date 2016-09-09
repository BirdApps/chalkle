require 'spec_helper'

describe Notify::BookingNotification  do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:booking) { FactoryGirl.create(:booking, chalkler: chalkler, booker: chalkler) }

  describe ".confirmation" do
    it "notifies chalkler" do
      expect { Notify.for(booking).confirmation }.to change { booking.chalkler.notifications.count }.by(1)
    end

    it "notifies teacher" do
      booking.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(booking).confirmation }.to change { booking.teacher.notifications.count }.by(1)
    end

    it "emails chalkler" do
      expect { Notify.for(booking).confirmation }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.chalkler.email }.count }.by(1)
    end

    it "emails teacher" do
      booking.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(booking).confirmation }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.teacher.email }.count }.by(1)
    end
  end

  describe ".reminder" do
    it "notifies chalkler" do
      expect { Notify.for(booking).reminder }.to change { booking.chalkler.notifications.count }.by(1)
    end

    it "emails chalkler" do
      expect { Notify.for(booking).reminder }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.chalkler.email }.count }.by(1)
    end
  end

  describe ".completed" do
    it "notifies chalkler" do
      expect { Notify.for(booking).completed }.to change { booking.chalkler.notifications.count }.by(1)
    end

    it "emails chalkler" do
      expect { Notify.for(booking).completed }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? chalkler.email }.count }.by(1)
    end
  end

  describe ".cancelled" do
    it "notifies chalkler" do
      expect { Notify.for(booking).cancelled }.to change { booking.chalkler.notifications.count }.by(1)
    end

    it "notifies teacher" do
      booking.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(booking).cancelled }.to change { booking.teacher.notifications.count }.by(1)
    end

    it "emails chalkler" do
      expect { Notify.for(booking).cancelled }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.chalkler.email }.count }.by(1)
    end

    it "emails teacher" do
      booking.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(booking).cancelled }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.teacher.email }.count }.by(1)
    end

    it "emails provider admin" do
      booking.provider = FactoryGirl.create :provider
      provider_admin = ProviderAdmin.create(chalkler: FactoryGirl.create(:admin_chalkler), provider: booking.provider)
      expect { Notify.for(booking).cancelled }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? booking.teacher.email }.count }.by(1)
    end
  end
end
