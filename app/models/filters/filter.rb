module Filters
  class Filter < ActiveRecord::Base
    belongs_to :chalkler
    has_many :rules, class_name: 'Filters::Rule'

    def overwrite_rule!(name, value)
    end
  end
end