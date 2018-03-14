require 'pry'
module LearnOpen
  module Lessons
    def self.get(editor:, client:, requested_lesson: nil, next_lesson_requested: nil,environment: Environment, logger: logger)
      lesson_data = if !requested_lesson && !get_next_lesson
        client.current_lesson
      elsif !requested_lesson && get_next_lesson
        client.next_lesson
      else
        client.lesson_by_name(requested_lesson)
      end
      return Readme.new(lesson_data, environment: environment, logger: logger) unless lesson_data[:lab]

      LabFactory.get(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
    end

  end
end
