require 'spec_helper'

describe ChalklerPreferences do
  let(:chalkler) { double('chalkler', email: 'test@user.com', email_frequency: 'weekly', email_categories: [1]) }
  let(:params) { { email: 'tested@user.com', email_frequency: 'none', email_categories: ['2', ''] } }

  describe '#initialize' do
    before { @email_prefs = ChalklerPreferences.new(chalkler) }

    it 'extracts the correct preferences' do
      @email_prefs.email.should eq('test@user.com')
      @email_prefs.email_frequency.should eq('weekly')
      @email_prefs.email_categories.should eq([1])
    end
  end

  describe '#update_attributes' do
    before do
      @new_chalkler = FactoryGirl.build(:chalkler)
      @email_prefs = ChalklerPreferences.new(@new_chalkler)
    end

    context 'saving' do
      it 'returns true for valid params' do
        @email_prefs.update_attributes(params).should be_true
      end

      it 'returns false for invalid params' do
        params.delete(:email)
        @email_prefs.update_attributes(params).should be_false
      end
    end

    context 'parameters' do
      it 'extracts the correct preferences' do
        cat1 = Category.create!(name: 'one')
        cat2 = Category.create!(name: 'two')

        @email_prefs.update_attributes(params)

        @email_prefs.email.should eq('tested@user.com')
        @email_prefs.email_frequency.should eq('none')
        @email_prefs.email_categories.should eq([2])

        @new_chalkler.email.should eq('tested@user.com')
        @new_chalkler.email_frequency.should eq('none')
        @new_chalkler.email_categories.should eq([2])
      end
    end
  end
end
