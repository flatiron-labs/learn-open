module LearnOpen
  module Environments
    class IDEEnvironment < BaseEnvironment
      def open_readme(lesson)
        if valid?(lesson)
          io.puts "Opening readme..."
          run_custom_command(:browser_open, {url: lesson.to_url})
        else
          run_custom_command(:open_lab, {lab_name: lesson.name})
        end
      end

      def open_jupyter_lab(lesson, location, editor)
        if valid?(lesson)
          io.puts "Opening Jupyter Lesson..."
          run_custom_command(:browser_open, {url: lesson.to_url})
        else
          run_custom_command(:open_lab, {lab_name: lesson.name})
        end
      end

      def open_lab(lesson, location, editor)
        case lesson
        when LearnOpen::Lessons::IosLesson
          super
        when method(:valid?)
          download_lesson(lesson, location)
          open_editor(lesson, location, editor)
          start_file_backup(lesson, location)
          install_dependencies(lesson, location)
          notify_of_completion
          open_shell
        else
          run_custom_command(:open_lab, {lab_name: lesson.name})
        end
      end

      def valid?(lesson)
        lesson.name == environment_vars['LAB_NAME']
      end

      def run_custom_command(command, message)
        home_dir = "/home/#{environment_vars['CREATED_USER']}"
        custom_commands_log = "#{home_dir}/.custom_commands.log"
        File.open(custom_commands_log, "a") do |f|
          f.puts({:command => command}.merge(message).to_json)
        end
      end
    end
  end
end
