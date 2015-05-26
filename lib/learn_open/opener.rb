module LearnOpen
  class Opener
    attr_reader   :editor, :client, :lessons_dir
    attr_accessor :lesson, :repo_dir

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
      fork_repo
      clone_repo
      open_with_editor
      cd_to_lesson
    end

    private

    def set_lesson
      if !lesson
        self.lesson = get_current_lesson_forked_repo
      else
        self.lesson = ensure_correct_lesson
      end

      self.repo_dir = lesson.split('/').last
    end

    def current_lesson
      @current_lesson ||= client.current_lesson
    end

    def get_current_lesson_forked_repo
      current_lesson.forked_repo
    end

    def ensure_correct_lesson
      # send given lesson to api and get back sanitized version
    end

    def fork_repo
      # send api request to fork
    end

    def clone_repo
      if !repo_exists?
        system("cd #{lessons_dir} && git clone git@github.com:#{lesson}.git")
      end
    end

    def repo_exists?
      File.exists?("#{lessons_dir}/#{repo_dir}")
    end

    def open_with_editor
      if editor
        system("cd #{lessons_dir}/#{repo_dir} && #{editor} .")
      end
    end

    def cd_to_lesson
      Dir.chdir("#{lessons_dir}/#{repo_dir}")
      exec(ENV['SHELL'])
    end
  end
end
