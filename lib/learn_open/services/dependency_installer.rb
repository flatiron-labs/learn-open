module LearnOpen
  class DependencyInstaller
    attr_reader :lesson, :location, :system_adapter, :io
    def self.call(lesson, location, options)
      self.new(lesson, location, options).call
    end

    def initialize(lesson, location, options)
      @lesson = lesson
      @location = location
      @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
      @io             = options.fetch(:io, LearnOpen.default_io)
    end

    def call
      if LearnOpen::Lessons::JupyterLesson === lesson && has_requirements_txt?
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("/opt/conda/bin/python -m pip install -r requirements.txt")
      end
    end

    private
    def has_requirements_txt?
      File.exists?("#{location}/#{lesson.name}/requirements.txt")
    end
  end
end
