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

      def open_lab(lesson, location, editor)
        case lesson
        when LearnOpen::Lessons::IosLesson
          LessonDownloader.call(lesson, location, options)
          open_xcode(lesson, location)
          notify_of_completion
          open_shell
        else
          super
        end
      end

      def xcodeproj_file?(lesson, location)
        Dir.glob("#{lesson.to_path}/*.xcodeproj").any?
      end

      def xcworkspace_file?(lesson, location)
        Dir.glob("#{lesson.to_path}/*.xcworkspace").any?
      end

      def open_xcode(lesson, location)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory("#{lesson.to_path}")
        if xcworkspace_file?(lesson, location)
          system_adapter.run_command("cd #{lesson.to_path} && open *.xcworkspace")
        elsif xcodeproj_file?(lesson, location)
          system_adapter.run_command("cd #{lesson.to_path} && open *.xcodeproj")
        end
      end
    end

    class MacWithChromeEnvironment < MacEnvironment
      def open_readme(lesson)
        io.puts "Opening readme..."
        system_adapter.run_command("open -a 'Google Chrome' #{lesson.to_url}")
      end
    end
  end
end
