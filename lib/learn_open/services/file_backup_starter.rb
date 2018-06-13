module LearnOpen
  class FileBackupStarter
    attr_reader :lesson, :location, :system_adapter

    def self.call(lesson, location, options)
      self.new(lesson, location, options).call
    end

    def initialize(lesson, location, options)
      @lesson = lesson
      @location = location
      @system_adapter = options.fetch(:system_adapter, LearnOpen.system_adapter)
    end

    def call
      system_adapter.spawn("restore-lab", block: true)
      system_adapter.watch_dir("#{lesson.to_path}", "backup-lab")
    end
  end
end
