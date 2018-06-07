module LearnOpen
  module Lessons
    class ReadmeLesson
      def self.detect(dot_learn)
        !!dot_learn[:lab]
      end
    end
  end
end
