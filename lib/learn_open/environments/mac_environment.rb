module LearnOpen
  module Environments
    class MacEnvironment < BaseEnvironment
      def self.classify(options)
        if chrome_installed?
          MacWithChromeEnvironment.new(options)
        else
          self.new(options)
        end
      end
      def self.chrome_installed?
        File.exists?('/Applications/Google Chrome.app')
      end

      def open_readme(lesson)
        io.puts "Opening readme..."
        system_adapter.run_command("open -a Safari #{lesson.to_url}")
      end
    end

    class MacWithChromeEnvironment < BaseEnvironment
      def open_readme(lesson)
        io.puts "Opening readme..."
        system_adapter.run_command("open -a 'Google Chrome' #{lesson.to_url}")
      end
    end

  end
end
