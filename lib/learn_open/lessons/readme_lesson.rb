module LearnOpen
  module Lessons
    class ReadmeLesson < Base
      def self.detect(lesson)
        !lesson[:lab]
      end

      def open(environment, _editor)
        warn_if_necessary
        environment.open_readme(self)
      end

      def to_url
        "https://learn.co/lessons/#{id}"
      end
    end
  end
end
