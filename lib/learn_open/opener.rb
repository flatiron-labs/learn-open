module LearnOpen
  class Opener
    HOME_DIR = File.expand_path("~")
    attr_reader   :editor, :client, :lessons_dir, :file_path, :get_next_lesson, :token
    attr_accessor :lesson, :repo_dir, :lesson_is_lab, :lesson_id, :later_lesson, :dot_learn

    def self.run(lesson:, editor_specified:, get_next_lesson:)
      new(lesson, editor_specified, get_next_lesson).run
    end

    def initialize(lesson, editor, get_next_lesson)
      _login, @token = Netrc.read['learn-config']
      @client        = LearnWeb::Client.new(token: @token)

      @lesson          = lesson
      @editor          = editor
      @get_next_lesson = get_next_lesson
      @lessons_dir     = YAML.load(File.read("#{HOME_DIR}/.learn-config"))[:learn_directory]
      @file_path       = "#{HOME_DIR}/.learn-open-tmp"
    end

    def run
      setup_tmp_file

      set_lesson

      if ide_version_3?
        if self.lesson != ENV['CURRENT_LAB']
          File.open(".custom_commands.log", "w+") do |f|
            f.puts %Q{{"command": "open_lab", "lab_name": #{self.lesson}}}
          end
          exit
        end
      end

      warn_if_necessary

      if lesson_is_readme?
        open_readme
      else
        git_tasks
        file_tasks
        dependency_tasks
        completion_tasks
      end
    end

    def repo_exists?
      File.exists?("#{lessons_dir}/#{repo_dir}/.git")
    end

    private

    def ping_fork_completion(retries=3)
      begin
        Timeout::timeout(15) do
          client.submit_event(
            event: 'fork',
            learn_oauth_token: token,
            repo_name: repo_dir,
            base_org_name: lesson.split('/')[0],
            forkee: { full_name: nil }
          )
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem forking and cloning this lesson. Retrying..."
          ping_fork_completion(retries-1)
        else
          puts "There is an issue connecting to Learn. Please try again."
          File.write(file_path, 'ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def warn_if_necessary
      temp_args = nil

      if self.later_lesson
        puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
        print 'Are you sure you want to continue? [Yn]: '

        if ARGV.any?
          temp_args = ARGV
          ARGV.clear
        end

        warn_response = gets.chomp.downcase

        if !warn_response.empty? && !['yes', 'y'].include?(warn_response)
          exit
        end
      end

      if temp_args
        temp_args.each do |arg|
          ARGV << arg
        end
      end
    end

    def setup_tmp_file
      FileUtils.touch(file_path)
      File.write(file_path, '')
    end

    def cleanup_tmp_file
      File.write(file_path, 'Done.')
    end

    def set_lesson
      File.write(file_path, 'Getting lesson...')

      if !lesson && !get_next_lesson
        puts "Getting current lesson..."
        self.lesson        = get_current_lesson_forked_repo
        self.lesson_is_lab = current_lesson.lab
        self.lesson_id     = current_lesson.id
        self.later_lesson  = false
        self.dot_learn     = current_lesson.dot_learn
      elsif !lesson && get_next_lesson
        puts "Getting next lesson..."
        self.lesson        = get_next_lesson_forked_repo
        self.lesson_is_lab = next_lesson.lab
        self.lesson_id     = next_lesson.id
        self.later_lesson  = false
        self.dot_learn     = next_lesson.dot_learn
      else
        puts "Looking for lesson..."
        self.lesson        = ensure_correct_lesson.clone_repo
        self.lesson_is_lab = correct_lesson.lab
        self.lesson_id     = correct_lesson.lesson_id
        self.later_lesson  = correct_lesson.later_lesson
        self.dot_learn     = correct_lesson.dot_learn
      end

      self.repo_dir = lesson.split('/').last
    end

    def current_lesson
      @current_lesson ||= client.current_lesson
    end

    def next_lesson
      @next_lesson ||= client.next_lesson
    end

    def get_current_lesson_forked_repo(retries=3)
      begin
        Timeout::timeout(15) do
          current_lesson.clone_repo
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem getting your lesson from Learn. Retrying..."
          get_current_lesson_forked_repo(retries-1)
        else
          puts "There seems to be a problem connecting to Learn. Please try again."
          File.write(file_path, 'ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def get_next_lesson_forked_repo(retries=3)
      begin
        Timeout::timeout(15) do
          next_lesson.clone_repo
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem getting your next lesson from Learn. Retrying..."
          get_next_lesson_forked_repo(retries-1)
        else
          puts "There seems to be a problem connecting to Learn. Please try again."
          File.write(file_path, 'ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def ensure_correct_lesson
      correct_lesson
    end

    def correct_lesson(retries=3)
      @correct_lesson ||= begin
        Timeout::timeout(15) do
          client.validate_repo_slug(repo_slug: lesson)
        end
      rescue Timeout::Error
        if retries > 0
          puts "There was a problem connecting to Learn. Retrying..."
          correct_lesson(retries-1)
        else
          puts "Cannot connect to Learn right now. Please try again."
          File.write(file_path, 'ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def fork_repo(retries=3)
      if !repo_exists?
        File.write(file_path, 'Forking repository...')
        puts "Forking lesson..."

        if !dot_learn || dot_learn[:github] != false
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
              File.write(file_path, 'ERROR: Error connecting to Learn')
              exit
            end
          end
        end
      end
    end

    def clone_repo(retries=3)
      if !repo_exists?
        File.write(file_path, 'Cloning to your machine...')
        puts "Cloning lesson..."
        begin
          Timeout::timeout(15) do
            Git.clone("git@github.com:#{lesson}.git", repo_dir, path: lessons_dir)
          end
        rescue Git::GitExecuteError
          if retries > 0
            puts "There was a problem cloning this lesson. Retrying..." if retries > 1
            sleep(1)
            clone_repo(retries-1)
          else
            puts "Cannot clone this lesson right now. Please try again."
            File.write(file_path, 'ERROR: Error cloning. Try again.')
            exit
          end
        rescue Timeout::Error
          if retries > 0
            puts "There was a problem cloning this lesson. Retrying..."
            clone_repo(retries-1)
          else
            puts "Cannot clone this lesson right now. Please try again."
            File.write(file_path, 'ERROR: Error cloning. Try again.')
            exit
          end
        end
      end

      if dot_learn && dot_learn[:github] == false
        ping_fork_completion
      end
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

    def bundle_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{repo_dir}/Gemfile")
        puts "Bundling..."
        system("bundle install > /dev/null 2>&1")
      end
    end

    def npm_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{repo_dir}/package.json")
        puts 'Installing dependencies...'

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
      if can_open_readme?
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

    def ide_environment?
      ENV['IDE_CONTAINER'] == "true"
    end

    def ide_git_wip_enabled?
      ENV['IDE_GIT_WIP'] == "true"
    end

    def ide_version_3?
      ENV['IDE_VERSION'] == "3"
    end

    def git_tasks
      fork_repo
      clone_repo
    end

    def file_tasks
      cd_to_lesson
      open_with_editor
    end

    def dependency_tasks
      bundle_install
      npm_install
    end

    def restore_files
      pid = Process.spawn("restore-lab", [:out, :err] => File::NULL)
      Process.waitpid(pid)
    end

    def watch_for_changes
      Process.spawn("while inotifywait -e close_write,create,moved_to -r #{lessons_dir}/#{repo_dir}; do backup-lab; done", [:out, :err] => File::NULL)
    end

    def completion_tasks
      cleanup_tmp_file
      puts "Done."
      if ide_environment? && ide_git_wip_enabled?
        restore_files
        watch_for_changes
      end
      exec("#{ENV['SHELL']} -l")
    end
  end
end
