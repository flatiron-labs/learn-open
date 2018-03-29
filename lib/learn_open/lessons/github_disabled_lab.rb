module LearnOpen
  module Lessons
    class GithubDisabledLab < BaseLab
      def self.detect(lesson_data, environment)
        Hash(lesson_data[:dot_learn])[:github] == false
      end
      def open
        environment.warn_skipping_lessons if later_lesson
        git_tasks
        cd_to_lesson
        system("#{editor} .")
        dependency_tasks
        completion_tasks
      end
    end
  end
end
