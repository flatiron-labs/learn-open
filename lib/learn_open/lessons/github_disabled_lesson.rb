module LearnOpen
  module Lessons
    class GithubDisabledLesson < Base
      def self.detect(dot_learn)
        !dot_learn.nil? && dot_learn[:github] == false
      end
    end
  end
end
