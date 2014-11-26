require 'entity_events/interaction'
require 'entity_events/version'
require 'entity_events/event_finder'
require 'active_support/concern'

module EntityEvents

  extend ActiveSupport::Concern

  included do
    has_many  :interactions, as: :actor
    has_many  :interactions, as: :target
  end

  class << self
    def record(params, current_user)
      event_finder = EventFinder.find(params[:controller])
      entity_event = event_finder.new params, current_user
      entity_event.record
    end
  end

  class EntityEvent
    attr_reader :actor, :action ,:target, :params, :current_user

    def initialize(params,current_user)
      @params = params
      @action = action
      @current_user = current_user
      
      actor_method = (@action.to_s+'_actor').to_sym
      @actor = if respond_to?(actor_method)
        send actor_method
      else
        default_actor
      end

      begin
        target_method = (@action.to_s+'_target').to_sym
        @target = if respond_to?(target_method)
          send target_method
        else
          default_target
        end
      rescue
        @target = nil
      end

    end

    def record
      Interaction.log({
        actor:       actor,
        target:      target,
        action:      params[:action],
        controller:  params[:controller],
        parameters:  YAML::dump(params),
        flag:        params[:flag]
      })
    end

    def event_class
      self.class.name
    end

    #OVERRIDE FROM HERE
      def action
        params[:action]
      end

      def default_actor
        current_user
      end

      def default_target
        id = params["#{params[:controller].singularize}_id"] || params[:id]
        params[:controller].classify.constantize.find id
      end

  end

end
