module LearnOpen
  module Lessons
    class JupyterLesson < Base
      def self.detect(lesson)
        dot_learn = Hash(lesson[:dot_learn])
        !!dot_learn[:jupyter_notebook]
      end

      def open(environment, editor)
        environment.open_jupyter_lab(self, location, editor)
      end
    end
  end
end
