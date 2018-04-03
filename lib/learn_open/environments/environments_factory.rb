module LearnOpen
  module Environments
    class EnvironmentsFactory
      def self.get
        # Dirty
        if ENV['IDE_CONTAINER']
          if ENV['IDE_VERSION'] == "3"
            Environments::IDEV3Environment.new
          else
            Environments::IDELegacyEnvironment.new
          end
        elsif !!RUBY_PLATFORM.match(/darwin/)
          Environments::MacOSXEnvironment.new
        else
          Environments::GenericEnvironment.new
        end
      end
    end
  end
end
