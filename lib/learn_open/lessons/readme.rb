module LearnOpen
  module Lessons
    class Readme < BaseLesson
      def open(environment=Environment)
        if environment.ide?
          warn_skipping_lessons if later_lesson
          puts "Opening readme..."
          File.open(".custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "browser_open", "url": "https://learn.co/lessons/#{self.id}"}}
          end
        elsif environment.mac?
          puts "Opening readme..."
          launch_browser
        else
          puts "It looks like this lesson is a Readme. Please open it in your browser."
        end
      end

      def launch_browser
        if chrome_installed?
          open_chrome
        else
          open_safari
        end
      end

      def chrome_installed?
        File.exists?('/Applications/Google Chrome.app')
      end

      def open_chrome
        system("open -a 'Google Chrome' https://learn.co/lessons/#{lesson_id}")
      end

      def open_safari
        system("open -a Safari https://learn.co/lessons/#{lesson_id}")
      end
    end
  end
end
