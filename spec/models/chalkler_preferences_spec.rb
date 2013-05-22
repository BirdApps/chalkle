require 'spec_helper'

describe ChalklerPreferences do
  let(:chalkler) { double('chalkler', email: 'test@user.com', email_frequency: 'weekly', email_categories: [1], email_streams: [1]) }
  let(:params) { { email: 'tested@user.com', email_frequency: 'none', email_categories: ['2', ''], email_streams: ['2',''] } }

  describe '#initialize' do
    before { @email_prefs = ChalklerPreferences.new(chalkler) }

    it 'extracts an email' do
      @email_prefs.email.should eq('test@user.com')
    end

    it 'extracts an email_frequency' do
      @email_prefs.email_frequency.should eq('weekly')
    end

    it 'extracts the eamil categories' do
      @email_prefs.email_categories.should eq([1])
    end

    it 'extracts the eamil streams' do
      @email_prefs.email_streams.should eq([1])
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
      before { @email_prefs.update_attributes(params) }

      it 'extracts an email' do
        @email_prefs.email.should eq('tested@user.com')
      end

      it 'extracts an email_frequency' do
        @email_prefs.email_frequency.should eq('none')
      end

      it 'extracts the email categories' do
        @email_prefs.email_categories.should eq([2])
      end

      it 'extracts the email streams' do
        @email_prefs.email_streams.should eq([2])
      end

      it 'extracts an email' do
        @new_chalkler.email.should eq('tested@user.com')
      end

      it 'extracts an email_frequency' do
        @new_chalkler.email_frequency.should eq('none')
      end

      it 'extracts the eamil categories' do
        @new_chalkler.email_categories.should eq([2])
      end

      it 'extracts the eamil streams' do
        @new_chalkler.email_streams.should eq([2])
      end
    end
  end
end
