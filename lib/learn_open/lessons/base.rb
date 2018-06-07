module LearnOpen
  module Lessons
    class Base
      attr_reader :repo_path, :organization, :name, :id, :dot_learn, :later_lesson
      def initialize(lesson_data)
        lesson = lesson_data[:lesson]

        @repo_path     = lesson.clone_repo
        @organization, @name = repo_path.split('/')
        @id            = lesson.lesson_id
        @dot_learn     = lesson.dot_learn
        @later_lesson  = lesson_data[:later_lesson]
        @is_lab        = lesson[:lab]
      end

      def lab?
        @is_lab
      end

      def readme?
        !lab?
      end
    end
  end
end
