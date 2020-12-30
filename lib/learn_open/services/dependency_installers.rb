# frozen_string_literal: true

module LearnOpen
  module DependencyInstallers
    def self.installer_types
      [
        PipInstaller,
        GemInstaller,
        NodeInstaller
      ]
    end

    def self.run_installers(lesson, location, environment, options)
      installer_types.each do |type|
        type.call(lesson, location, environment, options) if type.detect(lesson, location)
      end
    end
  end
end
