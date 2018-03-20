module LearnOpen
  module Lessons
    class GenericLab < BaseLab
      def open
        environment.warn_skipping_lessons if later_lesson
        git_tasks
        cd_to_lesson
        system("#{editor} .")
        if environment.ide? && environment.git_wip_enabled?
          restore_files
          watch_for_changes
        end
        dependency_tasks
        completion_tasks
      end
    end
  end
end
