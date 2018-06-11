module LearnOpen
  module Lessons
    class GithubDisabledLesson < Base
      def self.detect(lesson)
        Hash(lesson[:dot_learn])[:github] == false
      end
    end
  end
end
