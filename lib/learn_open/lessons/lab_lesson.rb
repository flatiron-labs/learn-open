module LearnOpen
  module Lessons
    class LabLesson < BaseLesson
      def open(environment, editor)
        environment.open_lab(self, location, editor)
      end
    end
  end
end
