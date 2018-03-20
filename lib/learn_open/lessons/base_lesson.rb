module LearnOpen
  module Lessons
    class BaseLesson
      attr_reader :full_path, :name, :repo_slug, :id, :later_lesson, :dot_learn, :logger, :environment
      def initialize(lesson_data, environment: Environment, logger:)
        @full_path    = lesson_data.fetch(:clone_repo)
        @name         = lesson_data.fetch(:repo_name)
        @repo_slug    = lesson_data.fetch(:repo_slug)
        @id           = lesson_data.fetch(:lesson_id)
        @later_lesson = lesson_data.fetch(:later_lesson)
        @dot_learn    = lesson_data.fetch(:dot_learn)
        @environment  = environment
        @logger       = logger
      end
    end
  end
end
