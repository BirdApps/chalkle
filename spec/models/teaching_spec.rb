require 'spec_helper'

describe "Teachings" do
  let(:chalkler) { FactoryGirl.create(:chalkler) }
  let(:group) { FactoryGirl.create(:group) }
  let(:params) { { title: 'My new class', lesson_skill: '', do_during_class: 'We will play with Wii', learning_outcomes: 'and become experts at tennis', duration: '',
  free_lesson: '0', teacher_cost: '', max_attendee: '', min_attendee: '', availabilities: '' , additional_comments: ''} }

  before do
    chalkler.groups << group
    @chalkler_teaching = Teaching.new(chalkler)
  end

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

    #it "returns false when teacher cost is nonzero and donation box is checked" do
      #params[:donation] = '1'
      #params[:teacher_cost] = '10'
      #@chalkler_teaching.check_valid_input(params).should be_false
    #end

    it "returns false when min number of attendee is not an integer" do
      params[:min_attendee] = '1.3'
      @chalkler_teaching.check_valid_input(params).should be_false
    end

    it "returns false when max number of attendee is not an integer" do
      params[:max_attendee] = '10.3'
      @chalkler_teaching.check_valid_input(params).should be_false
    end
  end

  describe "form submit" do

  	let(:params2) { { title: 'My new class', lesson_skill: 'Beginner', do_during_class: 'We will play with Wii', learning_outcomes: 'and become experts at tennis', duration: '1',
    free_lesson: '0', teacher_cost: '20', max_attendee: '20', min_attendee: '5', availabilities: 'March 1st 2013' ,
    prerequisites: 'Wii controller and tennis racquet', additional_comments: 'Nothing elseto talk about'} }

  	it "create an unreviewed lesson with correct form" do
  		expect { @chalkler_teaching.submit(params2) }.to change(Lesson.unpublished, :count).by(1)
  	end

  	it "do not create an unreviewed lesson with empty form" do
  		expect { @chalkler_teaching.submit({}) }.not_to change(Lesson.unpublished, :count)
  	end

  	it "create a lesson with the correct name" do
  		@chalkler_teaching.submit(params2)
  		Lesson.find_by_name(params2[:title]).should be_valid
  	end

  	describe "created lesson" do
  	  before do
  	    @chalkler_teaching.submit(params2)
  	    @lesson = Lesson.find_by_name(params2[:title])
  	  end

  	    it "has the correct teacher" do
  	    	@lesson.teacher_id.should == chalkler.id
  	    end

        it "has the correct group" do
          @lesson.groups.should == chalkler.groups
        end

  	    it "has the correct lesson skill" do
  	    	@lesson.lesson_skill.should == params2[:lesson_skill]
  	    end

        it "has the correct what we will do during class" do
          @lesson.do_during_class.should == params2[:do_during_class]
        end

        it "has the correct what we will learn from class" do
          @lesson.learning_outcomes.should == params2[:learning_outcomes]
        end

  	    it "has the correct duration" do
  	    	@lesson.duration.should == params2[:duration].to_i*60*60
  	    end

        it "has the correct price" do
          @lesson.cost.should == 24
        end

        #it "has the correct donation setting" do
          #@lesson.donation.should be_false
        #end

  	    it "has the correct teacher cost" do
  	    	@lesson.teacher_cost.should == 20
  	    end

  	    it "has the correct max attendee" do
  	    	@lesson.max_attendee.should == params2[:max_attendee].to_i
  	    end

        it "has the correct min attendee" do
          @lesson.min_attendee.should == params2[:min_attendee].to_i
        end

        it "has the correct availabilities" do
          @lesson.availabilities.should == params2[:availabilities]
        end

        it "has the correct prerequisite" do
          @lesson.prerequisites.should == params2[:prerequisites]
        end

        it "has the correct additional comments" do
          @lesson.additional_comments.should == params2[:additional_comments]
        end
  	end
  end
end