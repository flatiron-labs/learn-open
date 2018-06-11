module LearnOpen
  module Environments
    class IDEEnvironment < BaseEnvironment
      def open_readme(lesson)
        if valid?(lesson)
          io.puts "Opening readme..."
          home_dir = "/home/#{environment_vars['CREATED_USER']}"
          File.open("#{home_dir}/.custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "browser_open", "url": "#{lesson.to_url}"}}
          end
        else
          home_dir = "/home/#{environment_vars['CREATED_USER']}"
          File.open("#{home_dir}/.custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
          end
        end
      end

      def open_lab(lesson, location, editor)
        if valid?(lesson)
          LessonDownloader.call(lesson, location, options)
          open_editor(lesson, location, editor)
          FileBackupStarter.call(lesson, location, options)
          DependencyInstaller.call(self, lesson, location, options)
          notify_of_completion
          open_shell
        else
          home_dir = "/home/#{environment_vars['CREATED_USER']}"
          File.open("#{home_dir}/.custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
          end
        end
      end

      def valid?(lesson)
        lesson.name == environment_vars['LAB_NAME']
      end
    end
  end
end
