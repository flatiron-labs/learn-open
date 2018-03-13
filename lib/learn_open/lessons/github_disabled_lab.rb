module LearnOpen
  module Lessons
    class GithubDisabled < BaseLab
      def open
        warn_skipping_lessons if later_lesson
        git_tasks
        cd_to_lesson
        system("#{editor} .")
        dependency_tasks
        completion_tasks
      end
    end
  end
end
