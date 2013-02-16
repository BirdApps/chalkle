require 'spec_helper'

describe Category do
  context "creation" do
    it { should validate_presence_of :name }
  end

  context "class methods" do
    let(:work) { double('work', name: 'work', id: 1) }
    let(:play) { double('play', name: 'play', id: 2) }
    let(:categories) { [work, play] }

    describe ".select_options" do
      it "provides an array of options that can be used in select dropdowns" do
        Category.stub(:all) { categories }

        required_array = [['Work', 1], ['Play', 2]]
        Category.select_options.should eq(required_array)
      end
    end
  end
end
