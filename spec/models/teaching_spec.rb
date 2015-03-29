require 'spec_helper'

describe "Teachings" do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:the_user) { FactoryGirl.create(:the_user) }
  let(:provider) { FactoryGirl.create(:provider, provider_rate_override: 0.1, teacher_percentage: 0.5) }
  let(:provider2) { FactoryGirl.create(:provider, provider_rate_override: 0.6, teacher_percentage: 0.1) }
  let(:params) { {
    name: 'My new class',
    do_during_class: 'We will play with Wii',
    learning_outcomes: 'and become experts at tennis',
    duration_hours: '1',
    duration_minutes: '0',
    free_course: '0',
    teacher_cost: '',
    max_attendee: '',
    min_attendee: '',
    availabilities: '' ,
    additional_comments: '',
    provider_id: provider.id,
    repeating: false,
    repeat_frequency: '',
    repeat_count: 1
  } }
  let!(:chalkler_teaching){ Teaching.new(the_user) }

  before(:each) do
    chalkler.providers << provider
    chalkler.providers << provider2
  end

  describe "initialize" do

  	it "assign current chalkler as teacher" do
  	  chalkler_teaching.teacher_id = chalkler.id
  	end

  end

  describe "form validation" do

  	it "returns true for all required inputs completed" do
  		expect(chalkler_teaching.send(:check_valid_input, params)).to be true
  	end

  	it "returns false without a class title" do
  		params[:name] = ''
  		expect(chalkler_teaching.send(:check_valid_input, params)).to be_falsey
  	end

  	it "returns false without what we do during class" do
  		params[:do_during_class] = ''
  		expect(chalkler_teaching.send(:check_valid_input, params)).to be_falsey
  	end

  	it "returns false without what we will learn during class" do
  		params[:learning_outcomes] = ''
  		expect(chalkler_teaching.send(:check_valid_input, params)).to be_falsey
  	end

  	it "returns false without a numerical teacher cost" do
  		params[:teacher_cost] = 'ABC'
  		expect(chalkler_teaching.send(:check_valid_input, params)).to be_falsey
  	end

  end

  
end
