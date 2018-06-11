module LearnOpen
  module Lessons
    class ReadmeLesson < Base
      def self.detect(dot_learn)
        !dot_learn[:lab]
      end

      def open(location, editor)
        warn_if_necessary
        LearnOpen::Environments.classify(options).open_readme(self)
      end

      def to_url
        "https://learn.co/lessons/#{id}"
      end

      private
      def warn_if_necessary
        return unless self.later_lesson

        io.puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
        io.print 'Are you sure you want to continue? [Yn]: '

        warn_response = io.gets.chomp.downcase
        exit if !['yes', 'y'].include?(warn_response)
      end
    end
  end
end
