module LearnOpen
  module Lessons
    class JupyterLab < BaseLab
      def self.detect(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? {|file| file.end_with?("ipynb")}
      end

      def open
        git_tasks
        cd_to_lesson
        system("#{editor} .")
        if environment.supports_wip?
          restore_files
          watch_for_changes
        end
        dependency_tasks
        completion_tasks
      end
    end
  end
end
