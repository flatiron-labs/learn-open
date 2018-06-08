module LearnOpen
  module Lessons
    class JupyterLesson < Base
      def self.detect(dot_learn)
        !!dot_learn[:jupyter_notebook]
      end

      def open(location)
        LessonDownloader.call(self, location)
      end
    end
  end
end
