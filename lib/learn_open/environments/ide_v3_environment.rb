module LearnOpen
  module Environments
    class IDEv3Environment < BaseEnvironment
      def open_readme(lesson)
        io.puts "Opening readme..."
        home_dir = "/home/#{environment_vars['CREATED_USER']}"
        File.open("#{home_dir}/.custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "browser_open", "url": "#{lesson.to_url}"}}
        end
      end
    end
  end
end
