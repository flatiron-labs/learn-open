module LearnOpen
  module DependencyInstallers
    class MixInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{lesson.to_path}/mix.exs")
      end

      def run
        io.puts "Installing Dependencies..."
        system_adapter.run_command("mix deps.get")
      end
    end
  end
end
