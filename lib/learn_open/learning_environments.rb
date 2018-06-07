module LearnOpen
  module LearningEnvironments
    def self.get(environment_adapter, platform, client, lessons_dir, logger, io, git_adapter, system_adapter)
      if ide_version_3?(environment_adapter)
        IDEv3.new(environment_adapter, platform, client, lessons_dir, logger, io, git_adapter, system_adapter)
      elsif jupyter_notebook_environment?(environment_adapter)
        JupyterContainer.new(environment_adapter, platform, client, lessons_dir, logger, io, git_adapter, system_adapter)
      else
        Generic.new(environment_adapter, platform, client, lessons_dir, logger, io, git_adapter, system_adapter)
      end
    end

    def self.ide_version_3?(environment_adapter)
      environment_adapter['IDE_VERSION'] == "3"
    end

    def self.jupyter_notebook_environment?(environment_adapter)
      environment_adapter['JUPYTER_CONTAINER'] == "true"
    end
  end
end
