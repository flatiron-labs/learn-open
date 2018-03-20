module LearnOpen
  module Lessons
    module LessonFactory
      def self.get(editor:, client:, requested_lesson: nil, next_lesson_requested: nil, environment: Environment, logger:)
        lesson_data = if !requested_lesson && !get_next_lesson
          client.current_lesson
        elsif !requested_lesson && get_next_lesson
          client.next_lesson
        else
          client.lesson_by_name(requested_lesson)
        end

        if ENV['IDE_CONTAINER']
          if ENV['IDE_VERSION'] == "3"
            environment = Environments::IDEV3.new
          else
            environment = Environments::IDELegacy.new
          end
        elsif !!RUBY_PLATFORM.match(/darwin/)
          environment = Environments::MacOSX.new
        else
          environment = Environments::Generic.new
        end
        # Return an environment MacEnvironment, IDEv3Environment, IDEv2Environment, ManagedJupyterEnvironment
        return Readme.new(lesson_data, environment: environment, logger: logger) unless lesson_data[:lab]

        LabFactory.get(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
      end
    end
  end
end
