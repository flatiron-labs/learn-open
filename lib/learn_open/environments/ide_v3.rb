module LearnOpen
  module Environments
    class IDEV3 < BaseEnvironment
      def valid?(lesson)
        lesson.name != ide_lab_name
      end

      def open_brower(lesson_url)
        File.open(".custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "browser_open", "url": lesson_url}}
        end
      end

      def ide_lab_name
        ENV['LAB_NAME']
      end
    end
  end
end
