module LearnOpen
  module LearningEnvironments
    class JupyterContainer < Base
      def open(lesson)
        git_tasks(lesson)
        file_tasks(lesson)
        restore_files
        watch_for_changes
        jupyter_pip_install
        completion_tasks
      end
    end
  end
end
