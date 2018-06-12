module LearnOpen
  module Environments
    class JuptyerContainerEnvironment < BaseEnvironment
      def open_jupyter_lab(lesson, location, editor)
        LessonDownloader.call(lesson, location, options)
        open_editor(lesson, location, editor)
        FileBackupStarter.call(lesson, location, options)
        LearnOpen::DependencyInstallers::JupyterPipInstall.call(lesson, location, self, options)
        notify_of_completion
        open_shell
      end

      def open_editor(lesson, location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory(lesson.to_path)
        system_adapter.open_editor(editor, path: ".")
      end

      def open_shell
        system_adapter.open_login_shell(environment_vars['SHELL'])
      end
    end
  end
end
