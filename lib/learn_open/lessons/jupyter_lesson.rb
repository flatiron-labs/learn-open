module LearnOpen
  module Lessons
    class JupyterLesson < Base
      def self.detect(lesson)
        dot_learn = Hash(lesson[:dot_learn])
        !!dot_learn[:jupyter_notebook]
      end

      def open(location, editor)
        LearnOpen::Environments.classify(options).open_jupyter_lab(self, location, editor)
      end
    end
  end
end
