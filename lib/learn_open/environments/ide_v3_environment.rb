module LearnOpen
  module Environments
    class IDEV3Environment < BaseEnvironment
      def supports_wip?; true; end
      def valid?(lesson)
        lesson.name == ide_lab_name
      end

      def open_browser(lesson_url, file_system=File)
        f = file_system.open(".custom_commands.log", "a")
        f.puts %Q{{"command": "browser_open", "url": lesson_url}}
        f.close
      end

      def ide_lab_name
        ENV['LAB_NAME']
      end
    end
  end
end
