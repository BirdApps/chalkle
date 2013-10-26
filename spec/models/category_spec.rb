require 'spec_helper'

describe Category do
  let(:parent) { Category.new(colour_num: 5, as: :admin) }

  context "creation" do
    it { should validate_presence_of :name }
  end

  context "class methods" do
    let(:work) { double('work', name: 'work', id: 1) }
    let(:play) { double('play', name: 'play', id: 2) }
    let(:categories) { [work, play] }

    describe ".select_options" do
      pending "provides an array of options that can be used in select dropdowns" do
        Category.stub(:all) { categories }

        required_array = [['Work', 1], ['Play', 2]]
        Category.select_options.should eq(required_array)
      end
    end
  end

  describe ".best_colour_num" do
    it "returns colour num if this category has one" do
      subject = Category.new(parent: parent, colour_num: 3)
      subject.best_colour_num.should == 3
    end

    it "returns parent colour num if this category doesn't have it's own" do
      subject = Category.new(parent: parent)
      subject.best_colour_num.should == 5
    end
  end
end
