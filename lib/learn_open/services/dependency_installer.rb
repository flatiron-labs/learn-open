module LearnOpen
  class DependencyInstaller
    attr_reader :lesson, :location, :system_adapter, :io, :environment
    def self.call(environment,lesson, location, options)
      self.new(environment, lesson, location, options).call
    end

    def initialize(environment, lesson,location, options)
      @lesson = lesson
      @location = location
      @environment = environment
      @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
      @io             = options.fetch(:io, LearnOpen.default_io)
    end

    def call
      case lesson
      when LearnOpen::Lessons::JupyterLesson
        if  has_requirements_txt?
          io.puts "Installing pip dependencies..."
          system_adapter.run_command("/opt/conda/bin/python -m pip install -r requirements.txt")
        end
      else
        if File.exists?("#{location}/#{lesson.name}/requirements.txt")
          io.puts "Installing pip dependencies..."
          system_adapter.run_command("python -m pip install -r requirements.txt")
        end

        if File.exists?("#{location}/#{lesson.name}/Gemfile")
          io.puts "Bundling..."
          system_adapter.run_command("bundle install")
        end

        if File.exists?("#{location}/#{lesson.name}/package.json")
          io.puts 'Installing npm dependencies...'

          case environment
          when LearnOpen::Environments::IDEEnvironment
            system_adapter.run_command("yarn install --no-lockfile")
          else
            system_adapter.run_command("npm install")
          end
        end
      end
    end

    private
    def has_requirements_txt?
      File.exists?("#{location}/#{lesson.name}/requirements.txt")
    end
  end
end
