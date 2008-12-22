if defined?(Merb::Plugins)
  dependency 'dm-core'

  require File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "connection"
  require File.dirname(__FILE__) / "merb" / "session" / "data_mapper_session"
  Merb::Plugins.add_rakefiles "merb_datamapper" / "merbtasks"

  class Merb::Orms::DataMapper::Connect < Merb::BootLoader
    after BeforeAppLoads

    def self.run
      Merb.logger.verbose! "Merb::Orms::DataMapper::Connect block."

      # check for the presence of database.yml
      if File.file?(Merb.dir_for(:config) / "database.yml")
        # if we have it, connect
        Merb::Orms::DataMapper.connect
      else
        # assume we'll be told at some point
        Merb.logger.info "No database.yml file found in #{Merb.dir_for(:config)}, assuming database connection(s) established in the environment file in #{Merb.dir_for(:config)}/environments"
      end

      # if we use a datamapper session store, require it.
      Merb.logger.verbose! "Checking if we need to use DataMapper sessions"
      if Merb::Config.session_stores.include?(:datamapper)
        Merb.logger.verbose! "Using DataMapper sessions"
        require File.dirname(__FILE__) / "merb" / "session" / "data_mapper_session"
      end

      # take advantage of the fact #id returns the key of the model, unless #id is a property
      Merb::Router.root_behavior = Merb::Router.root_behavior.identify(DataMapper::Resource => :id)

      Merb.logger.verbose! "Merb::Orms::DataMapper::Connect complete"
    end
  end

  class Merb::Orms::DataMapper::Associations < Merb::BootLoader
    after LoadClasses

    def self.run
      Merb.logger.verbose! 'Merb::Orms::DataMapper::Associations block'

      # make sure all relationships are initialized after loading
      descendants = DataMapper::Resource.descendants.dup
      descendants.each do |model|
        descendants.merge(model.descendants) if model.respond_to?(:descendants)
      end
      descendants.each do |model|
        model.relationships.each_value { |r| r.child_key }
      end

      Merb.logger.verbose! 'Merb::Orms::DataMapper::Associations complete'
    end
  end

  generators = File.join(File.dirname(__FILE__), 'generators')
  Merb.add_generators generators / 'data_mapper_model'
  Merb.add_generators generators / 'data_mapper_resource_controller'
  Merb.add_generators generators / 'data_mapper_migration'
end
