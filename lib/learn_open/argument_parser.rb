require 'optparse'

module LearnOpen
  class LessonManifest
    attr_reader :open_next, :lesson_name, :editor, :clone_only
    def initialize(open_next:, lesson_name:, editor:, clone_only:)
      @open_next = open_next
      @lesson_name = lesson_name
      @editor = editor
      @clone_only = clone_only
    end

    def to_a
      [lesson_name, editor, open_next, clone_only]
    end
  end
  class ArgumentParser
    attr_reader :args

    def initialize(args)
      @args = args
    end

    def parse
      options = {}
      rest = OptionParser.new do |opts|
        opts.on("--next", "open next lab") do |n|
          options[:next] = n
        end
        opts.on("--editor=EDITOR", "specify editor") do |e|
          options[:editor] = e
        end

        opts.on("--clone-only", "only download files. No shell") do |co|
          options[:clone_only] = co
        end
      end.parse(args)
      options[:lesson_name] = rest.first
      options
    end

    def learn_config_editor
      config_path = File.expand_path('~/.learn-config')
      editor = YAML.load(File.read(config_path))[:editor]
      editor.split.first
    end

    def execute
      cli_args = parse

      editor = cli_args[:editor].empty? ? learn_config_editor : cli_args[:editor]
      cli_args.merge!(editor: editor)

      [
        cli_args[:lesson_name],
        cli_args[:editor],
        cli_args[:next],
        cli_args[:clone_only]
      ]
    end
  end
end
