require 'spec_helper'
require 'omni_avatar/has_avatar'

describe "configuring OmniAvatar" do
  context "with no storage layer" do
    pending "raises an error when you try and include HasAvatar" do
      begin
        expect {
          module SpecClasses
            class Person
              include OmniAvatar::HasAvatar
            end
          end
        }.to raise_error
      end
    end

    it "doesn't raise an error if you have registered a storage layer" do

    end
  end
end