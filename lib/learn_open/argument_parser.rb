require 'optparse'

module LearnOpen
  class ArgumentParser
    attr_reader :args

    def initialize(args)
      @args = args
    end

    def execute
      options = {}
      rest = OptionParser.new do |opts|
        opts.on("--next", "open next lab") do |n|
          options[:next] = n
        end
        opts.on("--editor=EDITOR", "specify editor") do |e|
          options[:editor] = e
        end
      end.parse(args)
      config_path = File.expand_path('~/.learn-config')
      learn_config_editor = YAML.load(File.read(config_path))[:editor]

      if learn_config_editor =~ / /
        learn_config_editor = learn_config_editor.split(' ').first
      end

      editor = options[:editor].empty? ? learn_config_editor : options[:editor]

      lesson = rest.first
      next_lesson = options[:next]
      [lesson, editor, options[:next]]
    end
  end
end
