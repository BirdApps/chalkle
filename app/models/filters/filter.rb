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
      rule = current_filter_for(name)
      rule.destroy if rule
    end

    def set_view_type!(value)
      self.view_type = value
      save!
    end

    def apply_to(scope)
      rules.each do |rule|
        scope = rule.apply_to(scope)
      end
      scope
    end

    def current_or_empty_filter_for(name)
      current_filter_for(name) || build_rule_for(name)
    end

    def current_filter_for(name)
      rules.where(strategy_name: name).first
    end

    def build_rule_for(name)
      Rule.new(strategy_name: name)
    end

    def view_months?
      self.view_type == 'months'
    end

  end
end