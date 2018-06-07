module LearnOpen
  module Lessons
    class IosLesson < Base
      def self.detect(dot_learn)
        languages = dot_learn[:languages]
        (languages & ["swift", "objc"]).any?
      end
    end
  end
end
