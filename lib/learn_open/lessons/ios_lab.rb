module LearnOpen
  module Lessons
    class IosLab < BaseLab
      def open
        return puts "You need to be on a Mac to work on iOS lessons." unless environment.mac?
        warn_skipping_lessons if later_lesson
        git_tasks
        cd_to_lesson
        open_xcode
        completion_tasks
      end

      def open_xcode
        system("cd #{environment.lesson_dir(name)} && open #{xcode_file}")
      end

      def xcode_file
        environment.lesson_files.find do |file|
          file.end_with?("xcworkspace") || file.end_with?("xcodeproj")
        end
      end
    end
  end
end
