module LearnOpen
  module Environments
    def self.classify(options)
       environment_vars = options.fetch(:environment_vars, LearnOpen.environment_vars)
       platform         = options.fetch(:platform, LearnOpen.platform)
       if jupyter_container?(environment_vars)
         JuptyerContainerEnvironment.new(options)
       elsif ide_environment?(environment_vars)
         IDEv3Environment.new(options)
       elsif on_mac?(platform)
         MacEnvironment.classify(options)
       else
         GenericEnvironment.new(options)
       end
    end

    def self.jupyter_container?(environment_vars)
      environment_vars['JUPYTER_CONTAINER'] == "true"
    end
    def self.ide_environment?(environment_vars)
      environment_vars['IDE_CONTAINER'] == "true"
    end
    def self.on_mac?(platform)
      !!platform.match(/darwin/)
    end
  end
end
