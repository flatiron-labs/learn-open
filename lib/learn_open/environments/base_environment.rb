module LearnOpen
  module Environments
    class BaseEnvironment
      attr_reader :io, :environment_vars, :system_adapter, :options, :logger
      def initialize(options)
        @io               = options.fetch(:io, LearnOpen.default_io)
        @environment_vars = options.fetch(:environment_vars, LearnOpen.environment_vars)
        @system_adapter   = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @logger           = options.fetch(:logger, LearnOpen.logger)
        @options          = options
      end
      def open_jupyter_lab(location, editor); end
    end
  end
end
