module LearnOpen
  module Lessons
    class IosLab < BaseLab
      def self.detect(lesson_data, environment)
        languages   = lesson_data
                      .fetch(:dot_learn, {})
                      .fetch(:languages, [])
        ios_lang    = languages.any? {|l| ['objc', 'swift'].include?(l)}

        !!(ios_lang || xcodeproj_file?(lesson_data, environment) || xcworkspace_file?(lesson_data, environment))
      end

      def open
        return puts "You need to be on a Mac to work on iOS lessons." unless environment.mac?
        environment.warn_skipping_lessons if later_lesson
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

      def self.xcodeproj_file?(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? do |file|
          file.end_with?("xcodeproj")
        end
      end

      def self.xcworkspace_file?(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? do |file|
          file.end_with?("xcworkspace")
        end
      end
    end
  end
end
