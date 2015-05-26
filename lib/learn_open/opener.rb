module LearnOpen
  class Opener
    attr_reader   :editor, :client, :lessons_dir
    attr_accessor :lesson

    def self.run(lesson:, editor_specified:)
      new(lesson, editor_specified).run
    end

    def initialize(lesson, editor)
      _login, token = Netrc.read['learn-config']
      @client       = LearnWeb::Client.new(token: token)

      @lesson       = lesson
      @editor       = editor
      @lessons_dir  = YAML.load(File.read(File.expand_path('~/.learn-config')))[:directory]
    end

    def run
      set_lesson
      clone_repo
      Dir.chdir('/Users/loganhasson/Development')
      puts ENV['SHELL']
      puts ENV['SHELL'].split('/').last
      exec(ENV['SHELL'].split('/').last)

      exit
      # if !lesson, get current lesson path from api
      # if lesson, get correct lesson path from api
      #   clone
      #   cd
      #
      # if editor
      #   if binary exists
      #     open with binary
    end

    private

    def set_lesson
      if !lesson
        self.lesson = get_current_lesson
      else
        self.lesson = ensure_correct_lesson
      end
    end

    def get_current_lesson
      client.current_lesson.github_repo
    end

    def ensure_correct_lesson
      # send given lesson to api and get back sanitized version
    end

    def clone_repo
      # cd into lessons_dir and clone
    end
  end
end
