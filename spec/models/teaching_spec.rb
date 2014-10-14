require 'spec_helper'

describe "Teachings" do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.1, teacher_percentage: 0.5) }
  let(:channel2) { FactoryGirl.create(:channel, channel_rate_override: 0.6, teacher_percentage: 0.1) }
  let(:category) { FactoryGirl.create(:category, name: "music and dance") }
  let(:region)   { FactoryGirl.create(:region, name: 'Auckland') }
  let(:params) { {
    name: 'My new class',
    course_skill: '',
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
    category_primary_id: category.id,
    channel_id: channel.id,
    region_id: region.id,
    repeating: false,
    repeat_frequency: '',
    repeat_count: 1
  } }
  let(:chalkler_teaching){ Teaching.new(chalkler) }

  before(:each) do
    chalkler.channels << channel
    chalkler.channels << channel2
  end

  describe "initialize" do

  	it "assign current chalkler as teacher" do
  	  chalkler_teaching.teacher_id = chalkler.id
  	end

  end

  describe "form validation" do

  	it "returns true for all required inputs completed" do
  		expect(chalkler_teaching.check_valid_input(params)).to be true
  	end

  	it "returns false for blank form" do
  		expect(chalkler_teaching.check_valid_input({})).to be_falsey
  	end

  	it "returns false without a class title" do
  		params[:name] = ''
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without what we do during class" do
  		params[:do_during_class] = ''
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without what we will learn during class" do
  		params[:learning_outcomes] = ''
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without a numerical duration" do
  		params[:duration_hours] = 'ABC'
      params[:duration_minutes] = 'ABC'
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without a numerical teacher cost" do
  		params[:teacher_cost] = 'ABC'
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without a numerical maximum attendee" do
  		params[:max_attendee] = 'ABC'
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false without a numerical minimum attendee" do
  		params[:min_attendee] = 'ABC'
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

  	it "returns false when teacher cost is nonzero and free course is checked" do
  		params[:free_course] = '1'
  		params[:teacher_cost] = '10'
  		expect(chalkler_teaching.check_valid_input(params)).to be_falsey
  	end

    it "returns false when min number of attendee is not an integer" do
      params[:min_attendee] = '1.3'
      expect(chalkler_teaching.check_valid_input(params)).to be_falsey
    end

    it "returns false when max number of attendee is not an integer" do
      params[:max_attendee] = '10.3'
      expect(chalkler_teaching.check_valid_input(params)).to be_falsey
    end

    it "returns false when a primary category is not assigned" do
      params[:category_primary_id] = '0'
      expect(chalkler_teaching.check_valid_input(params)).to be_falsey
    end
  end

  describe "form submit" do
  	let(:category) { FactoryGirl.create(:category, name: "music and dance") }
    let(:params2) { { 
      name: 'My new class', 
      course_skill: 'Beginner', 
      do_during_class: 'We will play with Wii', 
      learning_outcomes: 'and become experts at tennis', 
      duration_hours: '1',
      duration_minutes: '0',
      free_course: '0', 
      teacher_cost: '20', 
      cost: '30', 
      max_attendee: '20', 
      min_attendee: '5', 
      availabilities: 'March 1st 2013' ,
      prerequisites: 'Wii controller and tennis racquet', 
      additional_comments: 'Nothing elseto talk about', 
      category_primary_id: category.id, 
      channel_id: channel.id, 
      region_id: region.id,
      start_at: Time.new(2013,3,1,18,00,00).to_s,
      repeating: 'once-off'
    } }

  	it "create an unreviewed course with correct form" do
  		expect { chalkler_teaching.submit(params2) }.to change(Course.unpublished, :count).by(1)
  	end

  	it "do not create an unreviewed course with empty form" do
  		expect { chalkler_teaching.submit({}) }.not_to change(Course.unpublished, :count)
  	end

  	describe "created course" do

      it "builds the course with the correct values" do
        id = chalkler_teaching.submit(params2)
        course = Course.find(id)
        expect(course.teacher_id).to eq chalkler.id
        expect(course.channel).to eq channel
        expect(course.course_skill).to eq params2[:course_skill]
        expect(course.category_id).to eq category.id
        expect(course.do_during_class).to eq params2[:do_during_class]
        expect(course.learning_outcomes).to eq params2[:learning_outcomes]
        expect(course.duration.to_i).to eq params2[:duration_hours].to_i*60*60+params2[:duration_minutes].to_i*60
        expect(course.teacher_cost).to eq 20
        expect(course.max_attendee).to eq params2[:max_attendee].to_i
        expect(course.min_attendee).to eq params2[:min_attendee].to_i
        expect(course.availabilities).to eq params2[:availabilities]
        expect(course.prerequisites).to eq params2[:prerequisites]
        expect(course.additional_comments).to eq params2[:additional_comments]
        expect(course.region).to eq region

      end
  	end
  end
end
