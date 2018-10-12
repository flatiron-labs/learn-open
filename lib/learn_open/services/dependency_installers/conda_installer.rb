module LearnOpen
  module DependencyInstallers
    class CondaInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{lesson.to_path}/environment.yml")
      end

      def run
        #  - conda env create -f environment.yml / conda env create -f windows.yml
        # - source activate learn-env / activate learn-env
        io.puts "Creating conda environment..."
        system_adapter.run_command("conda env create -f environment.yml")
        io.puts "Activating learn-env environmemnt..."
        system_adapter.run_command("source activate learn-env")
      end
    end
  end
end
