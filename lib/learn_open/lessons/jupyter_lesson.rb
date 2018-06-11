module LearnOpen
  module Lessons
    class JupyterLesson < Base
      def self.detect(dot_learn)
        !!dot_learn[:jupyter_notebook]
      end

      def open(location, editor, environment_vars)
        LessonDownloader.call(self, location, options)
        open_editor(location, editor)
        if running_on_container?
          FileBackupStarter.call(self, location, options)
        end
      end

      def open_editor(location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory("#{location}/#{name}")
        system_adapter.open_editor(editor, path: ".")
      end

      def running_on_container?
        environment_vars['JUPYTER_CONTAINER'] == "true"
      end
    end
  end
end
