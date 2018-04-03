module LearnOpen
  class ArgumentParser
    attr_reader :args

    def initialize(args)
      @args = args
    end

    def execute
      editor_data = from_config(:editor)

      options = {
        editor: String(editor_data),
        next: false
      }

      opts_parser = OptionParser.new do |opts|
        opts.on("-eEDITOR", "--editor=EDITOR", "specify editor" ) do |o|
          options[:editor] = o unless o.empty?
        end
        opts.on("-n", "--next", "open next lab") do
          options[:next] = true
        end
      end.parse!(args)
      [args.first, options[:editor], options[:next]]
    end

    private
    def from_config(option)
      config_path = File.expand_path('~/.learn-config')
      config = YAML.load(File.read(config_path))
      result = config[option.to_sym] || config[option.to_s]
      result.split(' ').first
    end
  end
end
