require 'spec_helper'

describe "Teachings" do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.1, teacher_percentage: 0.5) }
  let(:channel2) { FactoryGirl.create(:channel, channel_rate_override: 0.6, teacher_percentage: 0.1) }
  let(:category) { FactoryGirl.create(:category, name: "music and dance") }
  let(:region)   { FactoryGirl.create(:region, name: 'Auckland') }
  let(:params) { {
    title: 'My new class',
    course_skill: '',
    do_during_class: 'We will play with Wii',
    learning_outcomes: 'and become experts at tennis',
    duration: '',
    free_course: '0',
    teacher_cost: '',
    max_attendee: '',
    min_attendee: '',
    availabilities: '' ,
    additional_comments: '',
    category_primary_id: category.id,
    channel_id: channel.id,
    region_id: region.id
  } }

  before do
    chalkler.channels << channel
    chalkler.channels << channel2
    @chalkler_teaching = Teaching.new(chalkler)
  end

  describe "initialize" do

  	it "assign current chalkler as teacher" do
  	  @chalkler_teaching.teacher_id = chalkler.id
  	end

  end

  describe "form validation" do

  	it "returns true for all required inputs completed" do
  		@chalkler_teaching.check_valid_input(params).should be_true
  	end

  	it "returns false for blank form" do
  		@chalkler_teaching.check_valid_input({}). should be_false
  	end

  	it "returns false without a class title" do
  		params[:title] = ''
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without what we do during class" do
  		params[:do_during_class] = ''
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without what we will learn during class" do
  		params[:learning_outcomes] = ''
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without a numerical duration" do
  		params[:duration] = 'ABC'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without a numerical teacher cost" do
  		params[:teacher_cost] = 'ABC'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without a numerical maximum attendee" do
  		params[:max_attendee] = 'ABC'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false without a numerical minimum attendee" do
  		params[:min_attendee] = 'ABC'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

  	it "returns false when teacher cost is nonzero and free course is checked" do
  		params[:free_course] = '1'
  		params[:teacher_cost] = '10'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end

    it "returns false when min number of attendee is not an integer" do
      params[:min_attendee] = '1.3'
      @chalkler_teaching.check_valid_input(params).should be_false
    end

    it "returns false when max number of attendee is not an integer" do
      params[:max_attendee] = '10.3'
      @chalkler_teaching.check_valid_input(params).should be_false
    end

    it "returns false when a primary category is not assigned" do
      params[:category_primary_id] = '0'
      @chalkler_teaching.check_valid_input(params).should be_false
    end
  end

  describe "form submit" do

  	let(:category) { FactoryGirl.create(:category, name: "music and dance") }
    let(:params2) { { title: 'My new class', course_skill: 'Beginner', do_during_class: 'We will play with Wii', learning_outcomes: 'and become experts at tennis', duration: '1',
    free_course: '0', teacher_cost: '20', cost: '30', max_attendee: '20', min_attendee: '5', availabilities: 'March 1st 2013' ,
    prerequisites: 'Wii controller and tennis racquet', additional_comments: 'Nothing elseto talk about', category_primary_id: category.id, channel_id: channel.id, region_id: region.id} }

  	it "create an unreviewed course with correct form" do
  		expect { @chalkler_teaching.submit(params2) }.to change(Course.unpublished, :count).by(1)
  	end

  	it "do not create an unreviewed course with empty form" do
  		expect { @chalkler_teaching.submit({}) }.not_to change(Course.unpublished, :count)
  	end

    it "create a course with the correct name" do
      @chalkler_teaching.submit(params2)
      Course.find_by_name((category.name + ": " + params2[:title]).downcase).should be_valid
    end

  	describe "created course" do
  	  before do
  	    @chalkler_teaching.submit(params2)
  	    @course = Course.find_by_name((category.name + ": " + params2[:title]).downcase)
  	  end

      it "builds the course with the correct values" do
        @course.teacher_id.should == chalkler.id
        @course.channel.should == channel
        @course.course_skill.should == params2[:course_skill]
        @course.category_id.should == category.id
        @course.do_during_class.should == params2[:do_during_class]
        @course.learning_outcomes.should == params2[:learning_outcomes]
        @course.duration.should == params2[:duration].to_i*60*60
        @course.teacher_cost.should == 20
        @course.max_attendee.should == params2[:max_attendee].to_i
        @course.min_attendee.should == params2[:min_attendee].to_i
        @course.availabilities.should == params2[:availabilities]
        @course.prerequisites.should == params2[:prerequisites]
        @course.additional_comments.should == params2[:additional_comments]
        @course.region.should == region
      end
  	end
  end
end
