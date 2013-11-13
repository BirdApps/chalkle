module OmniAvatar
  class Engine < ::Rails::Engine
    isolate_namespace OmniAvatar

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded

        # TODO: For Rails 4.0, this will need to be
        #config.paths["db/migrate"].expanded.each do |expanded_path|
        #  app.config.paths["db/migrate"] << expanded_path
        #end
      end
    end
  end
end
