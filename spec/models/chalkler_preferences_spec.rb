require 'spec_helper'

describe ChalklerPreferences do
  let(:chalkler) { FactoryGirl.create(:chalkler, name: 'chalkler', email: 'test@user.com', email_frequency: 'weekly',) }
  let(:params) { { name: 'new chalkler name', email: 'tested@user.com', email_frequency: 'none'} }

  describe '#initialize' do
    before { @email_prefs = ChalklerPreferences.new(chalkler) }

    it 'extracts the correct preferences' do
      expect(@email_prefs.email).to eq('test@user.com')
      expect(@email_prefs.email_frequency).to eq('weekly')
    end
  end

  describe '#update_attributes' do
    before do
      @new_chalkler = FactoryGirl.build(:chalkler)
      @email_prefs = ChalklerPreferences.new(@new_chalkler)
    end

    context 'saving' do
      it 'returns true for valid params' do
        expect( @email_prefs.update_attributes(params)).to be true
      end

      it 'returns false for invalid params' do
        params.delete(:email)
        expect( @email_prefs.update_attributes(params)).to be false
      end
    end

    context 'parameters' do
      it 'extracts the correct preferences' do


        @email_prefs.update_attributes(params)

        expect( @email_prefs.email).to eq('tested@user.com')
        expect( @email_prefs.email_frequency).to eq('none')

        expect( @new_chalkler.email).to eq('tested@user.com')
        expect( @new_chalkler.email_frequency).to eq('none')
      end
    end
  end
end
