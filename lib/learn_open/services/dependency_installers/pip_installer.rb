module LearnOpen
  module DependencyInstallers
    class PipInstaller < BaseInstaller
      def self.detect(lesson, _location)
        File.exist?("#{lesson.to_path}/requirements.txt")
      end

      def run
        io.puts 'Installing pip dependencies...'
        system_adapter.run_command('python -m pip install -r requirements.txt')
      end
    end
  end
end
