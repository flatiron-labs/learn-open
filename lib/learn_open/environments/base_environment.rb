module LearnOpen
  module Environments
    class BaseEnvironment
      attr_reader :io, :environment_vars, :system_adapter, :options, :logger
      def initialize(options)
        @io               = options.fetch(:io, LearnOpen.default_io)
        @environment_vars = options.fetch(:environment_vars, LearnOpen.environment_vars)
        @system_adapter   = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @logger           = options.fetch(:logger, LearnOpen.logger)
        @options          = options
      end
      def open_jupyter_lab(location, editor); end

      def open_lab(lesson, location, editor)
        case lesson
        when LearnOpen::Lessons::IosLesson
          io.puts "You need to be on a Mac to work on iOS lessons."
          :noop
        else
          LessonDownloader.call(lesson, location, options)
          open_editor(lesson, location, editor)
          DependencyInstaller.call(self, lesson, location, options)
          notify_of_completion
          open_shell
        end
      end

      def open_editor(lesson, location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory(lesson.to_path)
        system_adapter.open_editor(editor, path: ".")
      end

      def open_shell
        system_adapter.open_login_shell(environment_vars['SHELL'])
      end

      def notify_of_completion
        logger.log("Done.")
        io.puts "Done."
      end
    end
  end
end
