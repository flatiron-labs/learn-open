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
      open_with_editor
      cd_to_lesson
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

    def get_current_lesson_forked_repo(retries=3)
      begin
        Timeout::timeout(15) do
          current_lesson.forked_repo
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem getting your lesson from Learn. Retrying..."
          get_current_lesson_forked_repo(retries-1)
        else
          puts "There seems to be a problem connecting to Learn. Please try again."
          exit
        end
      end
    end

    def ensure_correct_lesson(retries=3)
      begin
        Timeout::timeout(15) do
          client.validate_repo_slug(repo_slug: lesson).repo_slug
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem connecting to Learn. Retrying..."
          ensure_correct_lesson(retries-1)
        else
          puts "Cannot connect to Learn right now. Please try again."
          exit
        end
      end
    end

    def fork_repo(retries=3)
      if !repo_exists?
        puts "Forking lesson..."
        begin
          Timeout::timeout(15) do
            client.fork_repo(repo_name: repo_dir)
          end
        rescue Timeout::Error
          if retries > 0
            puts "There was a problem forking this lesson. Retrying..."
            fork_repo(retries-1)
          else
            puts "There is an issue connecting to Learn. Please try again."
            exit
          end
        end
      end
    end

    def clone_repo(retries=3)
      if !repo_exists?
        puts "Cloning lesson..."
        begin
          Timeout::timeout(15) do
            Git.clone("git@github.com:#{lesson}.git", repo_dir, path: lessons_dir)
          end
        rescue Timeout::Error
          if retries > 0
            puts "There was a problem cloning this lesson. Retrying..."
            clone_repo(retries-1)
          else
            puts "Cannot clone this lesson right now. Please try again."
            exit
          end
        end
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
      puts "Opening lesson..."
      Dir.chdir("#{lessons_dir}/#{repo_dir}")
      puts "Bundling..."
      system("bundle install &>/dev/null")
      puts "Done."
      exec(ENV['SHELL'])
    end
  end
end
