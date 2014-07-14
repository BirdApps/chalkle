#require 'spec_helper_lite'
#require 'active_support/concern'
#require 'categorizable'
#
#describe Categorizable do
#  class ConcreteCategorizable
#    include Categorizable
#
#    def initialize
#      @categories = []
#    end
#
#    attr_accessor :categories
#  end
#
#  class Category
#  end
#
#  let(:category) { double(:category) }
#  subject { ConcreteCategorizable.new }
#
#  describe "#set_category" do
#    it "should create an association" do
#      Category.should_receive(:find_by_name).with('category').and_return(category)
#      subject.set_category 'category: a new course'
#      course.categories.should include category
#    end
#  end
#
#end