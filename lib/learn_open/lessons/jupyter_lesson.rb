module LearnOpen
  module Lessons
    class JupyterLesson < Base
      def self.detect(dot_learn)
        !!dot_learn[:jupyter_notebook]
      end

      def open(location, editor)
        LessonDownloader.call(self, location, options)
        open_editor(location, editor)
      end

      def open_editor(location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory("#{location}/#{name}")
        system_adapter.open_editor(editor, path: ".")
      end
    end
  end
end
