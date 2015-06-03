module LearnOpen
  class ArgumentParser
    attr_reader :args

    def initialize(args)
      @args = args
    end

    def execute
      config_path = File.expand_path('~/.learn-config')
      editor_data = YAML.load(File.read(config_path))[:editor]
      if editor_data.match(/ /)
        editor_data = editor_data.split(' ').first
      end

      lesson = nil

      configured_editor = !(editor_data.empty? || editor_data.nil?) ? editor_data : nil
      editor_specified = ARGV.detect {|arg| arg.start_with?('--editor=')}.match(/\-\-editor=(.+)/) || configured_editor
      open_after = !!editor_specified

      if !ARGV[0].start_with?('--editor=')
        lesson = ARGV[0]
      end

      if open_after
        editor_specified = editor_specified.is_a?(String) ? editor_specified : editor_specified[1]
      end

      [lesson, editor_specified]
    end
  end
end
