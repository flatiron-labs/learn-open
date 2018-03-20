module LearnOpen
  module Lessons
    class Readme < BaseLesson
      def open
        if environment.ide? || environment.mac?
          environment.warn_skipping_lessons if later_lesson
          logger.log_opening_readme
          environment.open_browser
        else
          logger.log_failed_to_open_readme
        end
      end
    end
  end
end
