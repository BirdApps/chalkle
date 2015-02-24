require 'spec_helper'

describe CourseNoticesController do
  let(:course) { FactoryGirl.create(:published_course) }
  let(:chalkler) { FactoryGirl.create(:chalkler) }

  describe "#create" do
    context "new course notice is created" do
      before { post :create, course_notice: FactoryGirl.attributes_for(:course_notice) }

      it "redirects to the course path" do
        expect(response).to redirect_to(provider_course_path(@course.provider.url_name, @course.url_name, @course.id)
      end
    end
  describe "#create" do
    context "new course notice with empty content" do
      before { post :create, course_notice: FactoryGirl.attributes_for(:course_notice)[:body] = '' }

      it "fails with empty content" do
        expect(flash[:notice]).to eq('You cannot post a comment without any content')
      end
    end

  end

end
