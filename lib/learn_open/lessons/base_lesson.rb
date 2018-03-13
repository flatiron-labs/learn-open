module LearnOpen
  module Lessons
    class BaseLesson
      attr_reader :full_path, :name, :repo_slug, :id, :later_lesson, :dot_learn, :client, :logger
      def initialize(lesson_data, client:, environment: Environment, logger: logger)
        @full_path    = lesson_data.fetch(:clone_repo)
        @name         = lesson_data.fetch(:repo_name)
        @repo_slug    = lesson_data.fetch(:repo_slug)
        @id           = lesson_data.fetch(:lesson_id)
        @later_lesson = lesson_data.fetch(:later_lesson)
        @dot_learn    = lesson_data.fetch(:dot_learn)
        @client       = client
        @environment  = environment
        @logger       = logger
      end

      def warn_skipping_lessons
        puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
        print 'Are you sure you want to continue? [Yn]: '

        warn_response = STDIN.gets.chomp.downcase
        exit if !['yes', 'y'].include?(warn_response)
      end

    end
  end
end
