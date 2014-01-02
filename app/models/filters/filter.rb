module Filters
  class Filter < ActiveRecord::Base
    belongs_to :chalkler
    has_many :rules, class_name: 'Filters::Rule'

    def overwrite_rule!(name, value)
      raise ArgumentError, "you must specify a rule name" if name.blank?

      rule = rules.first_or_initialize(strategy_name: name)
      rule.value = value
      rule.save!
    end

    def destroy_rule!(name)
      rule = rules.where(strategy_name: name).first
      rule.destroy if rule
    end

    def apply_to(scope)
      rules.each do |rule|
        scope = rule.apply_to(scope)
      end
      scope
    end

  end
end