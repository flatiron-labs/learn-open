module LearnOpen
  module Lessons
    class LabLesson < Base
      def open(location, editor)
        warn_if_necessary
        LearnOpen::Environments.classify(options).open_lab(self, location, editor)
      end
    end
  end
end
