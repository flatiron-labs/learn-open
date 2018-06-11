module LearnOpen
  module Lessons
    class Base
      attr_reader :repo_path,
        :organization,
        :name,
        :id,
        :dot_learn,
        :later_lesson,
        :options,
        :io,
        :system_adapter

      def initialize(lesson_data, options={})
        lesson = lesson_data[:lesson]

        @repo_path     = lesson.clone_repo
        @organization, @name = repo_path.split('/')
        @id            = lesson.lesson_id
        @dot_learn     = lesson.dot_learn
        @later_lesson  = lesson_data[:later_lesson]
        @is_lab        = lesson[:lab]

        @logger         = options.fetch(:logger, LearnOpen.logger)
        @io             = options.fetch(:io, LearnOpen.default_io)
        @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @options        = options
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
