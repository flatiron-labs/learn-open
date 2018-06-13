module LearnOpen
  module Environments
    class WindowsEnvironment < BaseEnvironment
      def open_readme(lesson)
        io.puts "Opening readme..."
        system_adapter.run_command("start #{lesson.to_url}")
      end

      def open_jupyter_lab(lesson, location, editor)
        io.puts "Opening Jupyter Lesson..."
        system_adapter.run_command("start #{lesson.to_url}")
      end
    end
  end
end
