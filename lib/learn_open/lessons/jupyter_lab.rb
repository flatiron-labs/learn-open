module LearnOpen
  module Lessons
    class JupyterLab < BaseLab
      def open
        git_tasks
        cd_to_lesson
        system("#{editor} .")
        if environment.managed_jupyter_environment?
          restore_files
          watch_for_changes
        end
        dependency_tasks
        completion_tasks
      end
    end
  end
end
