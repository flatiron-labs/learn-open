module LearnOpen
  class Opener
    HOME_DIR = File.expand_path("~")
    attr_reader   :editor, :client, :lessons_dir, :file_path, :get_next_lesson, :token, :logger, :lesson
    attr_accessor :requested_lesson, :repo_dir, :repo_name, :full_repo_path, :lesson_is_lab, :lesson_id, :later_lesson, :dot_learn

    def self.run(requested_lesson:, editor_specified:, get_next_lesson:)
      new(requested_lesson, editor_specified, get_next_lesson, LearnWrapper).run
    end

    def initialize(requested_lesson, editor, get_next_lesson, learn_wrapper=LearnWrapper)
      _login, @token    = Netrc.read['learn-config']
      @client           = learn_wrapper.new(token: @token)

      @requested_lesson = requested_lesson
      @file_path        = "#{HOME_DIR}/.learn-open-tmp"
      @logger           = DebugLogger.new(@file_path)
      @lesson           = Lessons.get(requested_lesson: requested_lesson, editor: editor, next_lesson_requested: get_next_lesson, client: @client, logger: @logger)
      @editor           = editor
      @get_next_lesson  = get_next_lesson
      @lessons_dir      = YAML.load(File.read("#{HOME_DIR}/.learn-config"))[:learn_directory]
    end

    def run
      if environment.valid?(lesson)
        puts "Looking for lesson..."
        lesson.open
      else
        environment.open(lesson)
      end
    end

    def repo_exists?
      File.exists?("#{lessons_dir}/#{repo_dir}/.git")
    end

    private

    def warn_skipping_lessons
      puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
      print 'Are you sure you want to continue? [Yn]: '

      warn_response = STDIN.gets.chomp.downcase
      exit if !['yes', 'y'].include?(warn_response)
    end

    def cleanup_tmp_file
      logger.log_done
    end

    def set_lesson
      logger.log_getting_lesson

      lesson = if !requested_lesson && !get_next_lesson
        current_lesson
      elsif !requested_lesson && get_next_lesson
        next_lesson
      else
        lesson_by_name(requested_lesson)
      end

      self.lesson        = lesson[:clone_repo]
      self.lesson_is_lab = lesson[:lab]
      self.lesson_id     = lesson[:lesson_id]
      self.later_lesson  = lesson[:later_lesson]
      self.dot_learn     = lesson[:dot_learn]

      self.repo_dir = self.lesson.split('/').last
      self.repo_name = self.lesson.split('/').last
      self.full_repo_path = self.lesson
      lesson
    end


    def current_lesson
      @current_lesson ||= client.current_lesson(&logger.method(:log_fetch_current_lesson))
    end

    def next_lesson
      @next_lesson ||= client.next_lesson(&logger.method(:log_fetch_next_lesson))
    end

    def lesson_by_name(repo_slug)
      client.lesson_by_name(repo_slug, &logger.method(:log_fetch_lesson))
    end

    def open_with_editor
      if ios_lesson?
        open_ios_lesson
      elsif editor
        system("#{editor} .")
      end
    end

    def ios_lesson?
      begin
        languages   = YAML.load(File.read("#{lessons_dir}/#{repo_dir}/.learn"))['languages']
        ios_lang    = languages.any? {|l| ['objc', 'swift'].include?(l)}

        ios_lang || xcodeproj_file? || xcworkspace_file?
      rescue Psych::SyntaxError
        if xcodeproj_file? || xcworkspace_file?
          true
        else
          puts "Sorry, there seems to be a problem with this lesson. Please submit a bug report to bugs@learn.co and try again later."
          puts "If you'd like to work on your next lesson now, type: learn next"
          File.write(file_path, 'ERROR: Problem parsing lesson data. Try again.')
          exit
        end
      rescue NoMethodError, Errno::ENOENT => e
        if xcodeproj_file? || xcworkspace_file?
          true
        elsif e.message.match(/for false:FalseClass/) || e.message.match(/No such file or directory/)
          false
        else
          puts "Sorry, there seems to be a problem with this lesson. Please submit a bug report to bugs@learn.co and try again later."
          puts "If you'd like to work on your next lesson now, type: learn next"
          File.write(file_path, 'ERROR: Problem parsing lesson data. Try again.')
          exit
        end
      end
    end

    def open_ios_lesson
      if can_open_ios_lesson?
        open_xcode
      else
        puts "You need to be on a Mac to work on iOS lessons."
        exit
      end
    end

    def can_open_ios_lesson?
      on_mac?
    end

    def open_xcode
      if xcworkspace_file?
        system("cd #{lessons_dir}/#{repo_dir} && open *.xcworkspace")
      elsif xcodeproj_file?
        system("cd #{lessons_dir}/#{repo_dir} && open *.xcodeproj")
      end
    end

    def xcodeproj_file?
      Dir.glob("#{lessons_dir}/#{repo_dir}/*.xcodeproj").any?
    end

    def xcworkspace_file?
      Dir.glob("#{lessons_dir}/#{repo_dir}/*.xcworkspace").any?
    end

    def cd_to_lesson
      puts "Opening lesson..."
      Dir.chdir("#{lessons_dir}/#{repo_dir}")
    end

    def pip_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{repo_dir}/requirements.txt")
        puts "Installing pip dependencies..."
        system("pip install -r requirements.txt")
      end
    end

    def bundle_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{repo_dir}/Gemfile")
        puts "Bundling..."
        system("bundle install")
      end
    end

    def npm_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{repo_dir}/package.json")
        puts 'Installing npm dependencies...'

        if ide_environment?
          system("yarn install --no-lockfile")
        else
          system("npm install")
        end
      end
    end

    def lesson_is_readme?
      !lesson_is_lab
    end

    def open_readme
      if ide_environment?
        puts "Opening readme..."
        File.open(".custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "browser_open", "url": "https://learn.co/lessons/#{lesson_id}"}}
        end
      elsif can_open_readme?
        puts "Opening readme..."
        launch_browser
      else
        puts "It looks like this lesson is a Readme. Please open it in your browser."
        exit
      end
    end

    def launch_browser
      if chrome_installed?
        open_chrome
      else
        open_safari
      end
    end

    def chrome_installed?
      File.exists?('/Applications/Google Chrome.app')
    end

    def open_chrome
      system("open -a 'Google Chrome' https://learn.co/lessons/#{lesson_id}")
    end

    def open_safari
      system("open -a Safari https://learn.co/lessons/#{lesson_id}")
    end

    def can_open_readme?
      on_mac?
    end

    def on_mac?
      !!RUBY_PLATFORM.match(/darwin/)
    end

    def github_disabled?
      !dot_learn.nil? && dot_learn[:github] == false
    end

    def ide_environment?
      ENV['IDE_CONTAINER'] == "true"
    end

    def ide_git_wip_enabled?
      return false if github_disabled?

      ENV['IDE_GIT_WIP'] == "true"
    end

    def ide_version_3?
      ENV['IDE_VERSION'] == "3"
    end

    def managed_jupyter_environment?
      ENV['JUPYTER_CONTAINER'] == "true"
    end

    def jupyter_notebook_lab?
      Dir.glob("#{lessons_dir}/#{repo_dir}/*.ipynb").any?
    end

    def git_tasks
      fork_repo(repo_name)
      clone_repo(full_repo_path, lessons_dir)
    end

    def fake_github_fork
      logger.log_fork_repo(:fake_starting)
    end

    def fork_repo(repo_name)
      if !repo_exists?
        if github_disabled?
          fake_github_fork
        else
          client.fork_repo(repo_name, &logger.method(:log_fork_repo))
        end
      end
    end

    def clone_repo(full_repo_path, repo_name)
      if !repo_exists?
        client.clone_repo(full_repo_path, repo_name, &logger.method(:log_clone_repo))
      end
      if github_disabled?
        client.ping_fork_completion(org_name, repo_name, &logger.method(:log_ping_fork_completion))
      end
    end

    def file_tasks
      cd_to_lesson
      open_with_editor
    end

    def dependency_tasks
      bundle_install
      npm_install
      pip_install
    end

    def restore_files
      pid = Process.spawn("restore-lab", [:out, :err] => File::NULL)
      Process.waitpid(pid)
    end

    def watch_for_changes
      Process.spawn("while inotifywait -e close_write,create,moved_to -r #{lessons_dir}/#{repo_dir}; do backup-lab; done", [:out, :err] => File::NULL)
    end

    def completion_tasks
      logger.log_done
      exec("#{ENV['SHELL']} -l")
    end
  end
end
