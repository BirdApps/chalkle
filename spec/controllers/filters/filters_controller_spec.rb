require 'spec_helper'

module Filters
  describe FiltersController do
    include Devise::TestHelpers

    describe "#create" do
      before do
        @region = FactoryGirl.create :region
      end

      def current_rule_should_be(key, value)
        filter = @current_chalkler.lesson_filter
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

            current_rule_should_be 'SingleRegion', @region.id.to_s
          end
        end

        context "with a filter" do
          it "sets the rule if none exists" do
            @current_chalkler.create_lesson_filter
            put :update, id: 'single_region', value: @region.id.to_s

            current_rule_should_be 'SingleRegion', @region.id.to_s
          end

          it "updates the rule if it has changed" do
            filter = @current_chalkler.create_lesson_filter
            filter.overwrite_rule! 'SingleRegion', FactoryGirl.create(:region).id

            put :update, id: 'single_region', value: @region.id.to_s

            current_rule_should_be 'SingleRegion', @region.id.to_s
          end
        end
      end
    end
  end
end