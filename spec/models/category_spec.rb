require 'spec_helper'

describe Category do
  let(:parent) { Category.new(colour_num: 5) }

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
        expect(Category.select_options).to eq(required_array)
      end
    end
  end

  describe ".best_colour_num" do
    it "returns colour num if this category has one" do
      subject = Category.new(parent: parent, colour_num: 3)
      expect(subject.best_colour_num).to eq 3
    end

    it "returns parent colour num if this category doesn't have it's own" do
      subject = Category.new(parent: parent)
      expect(subject.best_colour_num).to eq 5
    end
  end

  describe "slug" do
    it "returns lower case name" do
      expect(Category.new(name: 'Art').slug).to eq 'art'
    end

    it "replaces non word characters with a single underscore" do
      expect(Category.new(name: 'Art & science').slug).to eq 'art_science'
    end

    it "hyphenates with parent slug" do
      parent = Category.new(name: 'Art')
      expect(Category.new(parent: parent, name: 'Science & tech').slug).to eq 'art-science_tech'
    end
  end
end
