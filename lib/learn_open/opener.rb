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
      @lessons_dir  = YAML.load(File.read(File.expand_path('~/.learn-config')))[:learn_directory]
    end

    def run
      set_lesson
      fork_repo
      clone_repo
      open_lesson
      #cd_to_lesson
      #open_with_editor
    end

    private

    def set_lesson
      if !lesson
        puts "Getting current lesson..."
        self.lesson = get_current_lesson_forked_repo
      else
        puts "Looking for lesson..."
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
      client.validate_repo_slug(repo_slug: lesson).repo_slug
    end

    def fork_repo
      if !repo_exists?
        puts "Forking lesson..."
        client.fork_repo(repo_name: repo_dir)
      end
    end

    def clone_repo
      if !repo_exists?
        puts "Cloning lesson..."
        Git.clone("git@github.com:#{lesson}.git", repo_dir, path: lessons_dir)
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

    def open_lesson
      puts "Opening lesson..."
      Dir.chdir("#{lessons_dir}/#{repo_dir}")
      puts "Bundling..."
      system("bundle install")

      if editor
        exec("#{ENV['SHELL']} $(cd #{lessons_dir}/#{repo_dir} && #{editor} .)")
      else
        exec(ENV['SHELL'])
      end
    end
  end
end
