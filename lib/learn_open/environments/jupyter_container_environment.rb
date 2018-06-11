module LearnOpen
  module Environments
    class JuptyerContainerEnvironment < BaseEnvironment
      def open_jupyter_lab(lesson, location, editor)
        LessonDownloader.call(lesson, location, options)
        open_editor(lesson, location, editor)
        FileBackupStarter.call(lesson, location, options)
        if LearnOpen::Installers::JupyterPipInstall.detect(lesson, location)
          LearnOpen::Installers::JupyterPipInstall.call(lesson, location, self, options)
        end
        #DependencyInstaller.call(self, lesson, location, options)
        notify_of_completion
        open_shell
      end

      def open_editor(lesson, location, editor)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory("#{location}/#{lesson.name}")
        system_adapter.open_editor(editor, path: ".")
      end

      def open_shell
        system_adapter.open_login_shell(environment_vars['SHELL'])
      end
    end
  end
end
