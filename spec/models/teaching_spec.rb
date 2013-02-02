require 'spec_helper'

describe "Teachings" do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:params) { { title: 'My new class', lesson_type: '', do_during_class: 'We will play with Wii', learning_outcomes: 'and become experts at tennis', duration: '',
  free_lesson: '0', teacher_cost: '', max_attendee: '', min_attendee: '', suggested_dates: '' , anything_else: ''} }

  before {  @chalkler_teaching = Teaching.new(chalkler) }
  
  describe "initialize" do

  	it "assign current chalkler as teacher" do
  	  @chalkler_teaching.teacher_id = chalkler.id
  	end

  	it "extract the bio of current chalkler" do
  		@chalkler_teaching.bio = chalkler.bio
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

  	it "returns false when teacher cost is nonzero and free lesson is checked" do
  		params[:free_lesson] = '1'
  		params[:teacher_cost] = '10'
  		@chalkler_teaching.check_valid_input(params).should be_false
  	end
  end

  describe "price calculation" do
  	it "return 20% on top of input" do
  	  @chalkler_teaching.price_calculation(10).should == 12.0
  	end
  end

  describe "form submit" do

  	let(:params2) { { title: 'My new class', lesson_type: 'introduction', do_during_class: 'We will play with Wii', learning_outcomes: 'and become experts at tennis', duration: '60',
    free_lesson: '0', teacher_cost: '20', max_attendee: '20', min_attendee: '5', suggested_dates: 'March 1st 2013' , anything_else: 'Nothing'} }

  	it "create an unreviewed lesson with correct form" do
  		expect { @chalkler_teaching.submit(params2) }.to change(Lesson, :count).by(1)
  	end

  	it "do not create an unreviewed lesson with empty form" do
  		expect { @chalkler_teaching.submit({}) }.not_to change(Lesson, :count)
  	end

  	it "create a lesson with the correct name" do
  		@chalkler_teaching.submit(params2) 
  		Lesson.find_by_name(params2[:title]).should_not be_nil
  	end

  	describe "created lesson" do
  	  before do
  	    @chalkler_teaching.submit(params2)
  	    @lesson = Lesson.find_by_name(params2[:title])
  	  end

  	    it "has the correct teacher" do
  	    	@lesson.teacher_id.should == chalkler.id
  	    end

  	    it "has the correct lesson type" do
  	    	@lesson.lesson_type.should == 'intro'
  	    end

  	    it "has the correct duration" do
  	    	@lesson.lesson_type.should == params[:duration].to_i*60
  	    end

  	    it "has the correct teacher cost" do
  	    	@lesson.teacher_cost.should == 20
  	    end

  	    it "has the correct price" do
  	    	@lesson.cost.should == 24
  	    end
  	end
  end
end
