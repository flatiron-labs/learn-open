# frozen_string_literal: true

module LearnOpen
  class Logger
    attr_reader :log_path

    def initialize(log_path)
      @log_path = log_path
      setup
    end

    def log(message)
      File.write(log_path, message)
    end

    private

    def setup
      FileUtils.touch(log_path)
      File.write(log_path, '')
    end
  end
end
