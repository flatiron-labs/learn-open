module LearnOpen
    module Installers
      def self.installer_types
        [
          PipInstaller,
          GemInstaller,
          NodeInstaller
        ]
      end

      def self.run_installers(lesson, location, environment, options)
        installer_types.each do |type|
          if type.detect(lesson, location)
            type.call(lesson, location, environment, options)
          end
        end
      end
    class BaseInstaller
      attr_reader :lesson, :location, :system_adapter, :io, :environment
      def self.call(lesson, location, environment, options)
        self.new(lesson, location, environment, options).call
      end

      def initialize(lesson, location, environment, options)
        @lesson = lesson
        @location = location
        @environment = environment
        @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
        @io             = options.fetch(:io, LearnOpen.default_io)
      end
    end

    class GemInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{location}/#{lesson.name}/Gemfile")
      end

      def call
        io.puts "Bundling..."
        system_adapter.run_command("bundle install")
      end
    end

    class PipInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{location}/#{lesson.name}/requirements.txt")
      end
      def call
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("python -m pip install -r requirements.txt")
      end
    end

    class NodeInstaller < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{location}/#{lesson.name}/package.json")
      end

      def call
        io.puts 'Installing npm dependencies...'

        case environment
        when LearnOpen::Environments::IDEEnvironment
          system_adapter.run_command("yarn install --no-lockfile")
        else
          system_adapter.run_command("npm install")
        end
      end
    end

    class JupyterPipInstall < BaseInstaller
      def self.detect(lesson, location)
        File.exists?("#{location}/#{lesson.name}/requirements.txt")
      end

      def call
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("/opt/conda/bin/python -m pip install -r requirements.txt")
      end
    end
    end
  class DependencyInstaller
    attr_reader :lesson, :location, :system_adapter, :io, :environment, :options
    def self.call(environment,lesson, location, options)
      self.new(environment, lesson, location, options).call
    end

    def initialize(environment, lesson,location, options)
      @lesson = lesson
      @location = location
      @environment = environment
      @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
      @io             = options.fetch(:io, LearnOpen.default_io)
      @options        = options
    end


    def call
      case lesson
      when LearnOpen::Lessons::JupyterLesson
        if JupyterPipInstall.detect(lesson, location)
          JupyterPipInstall.call(lesson, location, environment, options)
        end
      else
        Installers.run_installers(lesson, location, environment, options)
      end
    end

    private
    def has_requirements_txt?
      File.exists?("#{location}/#{lesson.name}/requirements.txt")
    end
  end
end
