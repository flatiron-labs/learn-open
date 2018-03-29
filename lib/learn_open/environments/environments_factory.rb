module LearnOpen
  module Environments
    class EnvironmentsFactory
      def self.get
        # Dirty
        if ENV['IDE_CONTAINER']
          if ENV['IDE_VERSION'] == "3"
            Environments::IDEV3.new
          else
            Environments::IDELegacy.new
          end
        elsif !!RUBY_PLATFORM.match(/darwin/)
          Environments::MacOSX.new
        else
          Environments::Generic.new
        end
      end
    end
  end
end
