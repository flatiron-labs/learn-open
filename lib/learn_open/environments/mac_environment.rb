module LearnOpen
  module Environments
    class MacEnvironment < BaseEnvironment
      def self.classify(options)
        if chrome_installed?
          MacWithChromeEnvironment.new(options)
        else
          new(options)
        end
      end

      def self.chrome_installed?
        File.exist?('/Applications/Google Chrome.app')
      end

      def open_readme(lesson)
        io.puts 'Opening readme...'
        system_adapter.run_command("open -a Safari #{lesson.to_url}")
      end

      def open_jupyter_lab(lesson, _location, _editor, _clone_only)
        io.puts 'Opening Jupyter Lesson...'
        system_adapter.run_command("open -a Safari #{lesson.to_url}")
      end
    end

    class MacWithChromeEnvironment < MacEnvironment
      def open_readme(lesson)
        io.puts 'Opening readme...'
        system_adapter.run_command("open -a 'Google Chrome' #{lesson.to_url}")
      end

      def open_jupyter_lab(lesson, _location, _editor, _clone_only)
        io.puts 'Opening Jupyter Lesson...'
        system_adapter.run_command("open -a 'Google Chrome' #{lesson.to_url}")
      end
    end
  end
end
