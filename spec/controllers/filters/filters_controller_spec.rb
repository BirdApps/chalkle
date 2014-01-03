require 'spec_helper'

module Filters
  describe FiltersController do
    include Devise::TestHelpers

    describe "#create" do
      before do
        @region = FactoryGirl.create :region
      end

      def current_rule_should_be(key, value, filter = nil)
        filter ||= @current_chalkler.lesson_filter
        filter.should_not be_nil
        filter.rules.length.should == 1
        filter.rules.first.strategy_name.should == key
        filter.rules.first.value.should == value
      end

      context "with an authenticated user" do
        login_chalkler

        context "with no filter" do
          it "creates a filter and sets the rule" do
            put :update, id: 'single_region', value: @region.id.to_s

            current_rule_should_be 'single_region', @region.id.to_s
          end
        end

        context "with a filter" do
          it "sets the rule if none exists" do
            @current_chalkler.create_lesson_filter
            put :update, id: 'single_region', value: @region.id.to_s

            current_rule_should_be 'single_region', @region.id.to_s
          end

          it "updates the rule if it has changed" do
            filter = @current_chalkler.create_lesson_filter
            filter.overwrite_rule! 'single_region', FactoryGirl.create(:region).id

            put :update, id: 'single_region', value: @region.id.to_s

            current_rule_should_be 'single_region', @region.id.to_s
          end

          it "updates the view type" do
            filter = @current_chalkler.create_lesson_filter

            put :update, id: 'single_region', value: @region.id.to_s, view: 'months'

            filter.reload.view_type.should == 'months'
          end

        end
      end

      context "with a guest user" do
        context "with no filter" do
          it "creates a filter and stores it in the session" do
            put :update, id: 'single_region', value: @region.id.to_s

            filter = Filter.last
            filter.should_not be_nil
            current_rule_should_be 'single_region', @region.id.to_s, filter

            session[:filter_id].should == filter.id
          end
        end

        context "with a filter in the session" do
          it "sets the rule on the existing filter" do
            filter = Filter.create!
            session[:filter_id] = filter.id

            put :update, id: 'single_region', value: @region.id.to_s

            Filter.count.should == 1
            current_rule_should_be 'single_region', @region.id.to_s, filter
            session[:filter_id].should == filter.id
          end
        end
      end
    end

    describe "#update_view" do
      it "sets params to view_type in current filter"
    end
  end
end