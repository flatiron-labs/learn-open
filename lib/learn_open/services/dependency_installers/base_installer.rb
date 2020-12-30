module LearnOpen
  module DependencyInstallers
    class BaseInstaller
      attr_reader :lesson, :location, :system_adapter, :io, :environment

      def self.call(lesson, location, environment, options)
        new(lesson, location, environment, options).run if detect(lesson, location)
      end

      def initialize(lesson, location, environment, options)
        @lesson = lesson
        @location = location
        @environment = environment
        @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @io = options.fetch(:io, LearnOpen.default_io)
      end
    end
  end
end
