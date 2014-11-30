class Interaction < ActiveRecord::Base
  
  attr_accessible :controller, :action, :parameters, :description , :flag, :actor, :target, :actor_id, :target_id

  belongs_to :actor, polymorphic: true
  belongs_to :target, polymorphic: true
  
  def self.log( interaction )
    Interaction.create({
      actor: interaction[:actor],
      action: interaction[:action],
      controller: interaction[:controller],
      parameters: YAML::dump( interaction:[:params] ),
      target: interaction[:target],
      flag: interaction[:flag],
      description: interaction[:description]
    })
  end

  def params
    YAML::load(parameters)
  end

  #SOURCE/TARGET MODELS
  #booking
  #category
  #chalkler
  #channel
  #channel_admin
  #channel_contact
  #channel_plan
  #channel_teacher
  #course
  #course_notice
  #outgoing_payment
  #region
  #repeat_course
end