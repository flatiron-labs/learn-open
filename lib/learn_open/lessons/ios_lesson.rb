module LearnOpen
  module Lessons
    class IosLesson < Base
      def self.detect(lesson)
        languages = Hash(lesson[:dot_learn])[:languages]
        (languages & ["swift", "objc"]).any?
      end

      def open(location, editor)
        LearnOpen::Environments.classify(options).open_lab(self, location, editor)
      end
    end
  end
end
