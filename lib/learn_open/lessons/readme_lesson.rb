module LearnOpen
  module Lessons
    class ReadmeLesson < Base
      def self.detect(lesson)
        !lesson[:lab]
      end

      def open(location, editor)
        warn_if_necessary
        LearnOpen::Environments.classify(options).open_readme(self)
      end

      def to_url
        "https://learn.co/lessons/#{id}"
      end
    end
  end
end
