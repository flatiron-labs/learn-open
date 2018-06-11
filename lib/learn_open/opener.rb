module LearnOpen
  class Opener
    attr_accessor :repo_dir, :later_lesson, :lesson
    attr_reader :editor,
                :client,
                :lessons_dir,
                :target_lesson,
                :get_next_lesson,
                :token,
                :environment_vars,
                :git_adapter,
                :system_adapter,
                :io,
                :platform,
                :logger,
                :options

    def self.run(lesson:, editor_specified:, get_next_lesson:)
      new(lesson, editor_specified, get_next_lesson).run
    end

    def initialize(target_lesson, editor, get_next_lesson, options={})
      @target_lesson   = target_lesson
      @editor          = editor
      @get_next_lesson = get_next_lesson

      @options             = options
      @environment_vars    = options.fetch(:environment_vars, LearnOpen.environment_vars)
      @git_adapter         = options.fetch(:git_adapter, LearnOpen.git_adapter)
      @system_adapter      = options.fetch(:system_adapter, LearnOpen.system_adapter)
      @io                  = options.fetch(:io, LearnOpen.default_io)
      @platform            = options.fetch(:platform, LearnOpen.platform)
      @logger              = options.fetch(:logger, LearnOpen.logger)
      learn_client_class   = options.fetch(:learn_client_class, LearnOpen.learn_client)

      # wrapper
      _login, @token   = Netrc.read['learn-config']
      @client          = learn_client_class.new(token: @token)

      @options[:client] = @client

      home_dir         = File.expand_path("~")
      @lessons_dir     = YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
    end

    def run
      # log
      logger.log('Getting lesson...')

      # Fetching Lesson
      lesson_data = if !target_lesson && !get_next_lesson
        load_current_lesson
        {lesson: current_lesson, later_lesson: false}
      elsif !target_lesson && get_next_lesson
        load_next_lesson
        {lesson: next_lesson, later_lesson: false}
      else
        {lesson: correct_lesson, later_lesson: correct_lesson.later_lesson}
      end
      @lesson = Lessons.classify(lesson_data, options)

      if ide_version_3? && lesson.name != environment_vars['LAB_NAME']
        home_dir = "/home/#{environment_vars['CREATED_USER']}"
        File.open("#{home_dir}/.custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
        end
      else
        # user logging
        io.puts "Looking for lesson..."
        self.later_lesson  = lesson.later_lesson
        # Run on Correct Environment
        if jupyter_notebook_environment?
          @lesson.open(lessons_dir, editor, environment_vars)

          jupyter_pip_install
          completion_tasks
        else
          warn_if_necessary
          if lesson.readme?
            open_readme
          else
            fork_repo
            clone_repo
            cd_to_lesson
            open_with_editor
            if ide_environment? && ide_git_wip_enabled?
              restore_files
              watch_for_changes
              dependency_tasks
              completion_tasks
            else
              dependency_tasks
              completion_tasks
            end
          end
        end
      end

    end

    def repo_exists?
      File.exists?("#{lessons_dir}/#{lesson.name}/.git")
    end

    private
    def ping_fork_completion(retries=3)
      begin
        Timeout::timeout(15) do
          client.submit_event(
            event: 'fork',
            learn_oauth_token: token,
            repo_name: lesson.name,
            base_org_name: lesson.organization,
            forkee: { full_name: nil }
          )
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem forking and cloning this lesson. Retrying..."
          ping_fork_completion(retries-1)
        else
          io.puts "There is an issue connecting to Learn. Please try again."
          logger.log('ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def warn_if_necessary
      temp_args = nil

      if self.later_lesson
        io.puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
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

    def current_lesson
      @current_lesson ||= client.current_lesson
    end

    def next_lesson
      @next_lesson ||= client.next_lesson
    end

    def load_current_lesson(retries=3)
      begin
        Timeout::timeout(15) do
          current_lesson
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem getting your lesson from Learn. Retrying..."
          load_current_lesson(retries-1)
        else
          io.puts "There seems to be a problem connecting to Learn. Please try again."
          logger.log('ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def load_next_lesson(retries=3)
      begin
        Timeout::timeout(15) do
          next_lesson
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem getting your next lesson from Learn. Retrying..."
          load_next_lesson(retries-1)
        else
          io.puts "There seems to be a problem connecting to Learn. Please try again."
          logger.log('ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def correct_lesson(retries=3)
      @correct_lesson ||= begin
        Timeout::timeout(15) do
          client.validate_repo_slug(repo_slug: target_lesson)
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem connecting to Learn. Retrying..."
          correct_lesson(retries-1)
        else
          io.puts "Cannot connect to Learn right now. Please try again."
          logger.log('ERROR: Error connecting to Learn')
          exit
        end
      end
    end

    def fork_repo(retries=3)
      if !repo_exists?
        logger.log('Forking repository...')
        io.puts "Forking lesson..."

        if !github_disabled?
          begin
            Timeout::timeout(15) do
              client.fork_repo(repo_name: lesson.name)
            end
          rescue Timeout::Error
            if retries > 0
              io.puts "There was a problem forking this lesson. Retrying..."
              fork_repo(retries-1)
            else
              io.puts "There is an issue connecting to Learn. Please try again."
              logger.log('ERROR: Error connecting to Learn')
              exit
            end
          end
        end
      end
    end

    def clone_repo(retries=3)
      if !repo_exists?
        logger.log('Cloning to your machine...')
        io.puts "Cloning lesson..."
        begin
          Timeout::timeout(15) do
            git_adapter.clone("git@github.com:#{lesson.repo_path}.git", lesson.name, path: lessons_dir)
          end
        rescue Git::GitExecuteError
          if retries > 0
            io.puts "There was a problem cloning this lesson. Retrying..." if retries > 1
            sleep(1)
            clone_repo(retries-1)
          else
            io.puts "Cannot clone this lesson right now. Please try again."
            logger.log('ERROR: Error cloning. Try again.')
            exit
          end
        rescue Timeout::Error
          if retries > 0
            io.puts "There was a problem cloning this lesson. Retrying..."
            clone_repo(retries-1)
          else
            io.puts "Cannot clone this lesson right now. Please try again."
            logger.log('ERROR: Error cloning. Try again.')
            exit
          end
        end
      end

      if github_disabled?
        ping_fork_completion
      end
    end

    def open_with_editor
      if ios_lesson?
        open_ios_lesson
      elsif editor
        system_adapter.open_editor(editor, path: ".")
      end
    end

    def ios_lesson?
      begin
        languages   = YAML.load(File.read("#{lessons_dir}/#{lesson.name}/.learn"))['languages']
        ios_lang    = languages.any? {|l| ['objc', 'swift'].include?(l)}

        ios_lang || xcodeproj_file? || xcworkspace_file?
      rescue Psych::SyntaxError
        if xcodeproj_file? || xcworkspace_file?
          true
        else
          io.puts "Sorry, there seems to be a problem with this lesson. Please submit a bug report to bugs@learn.co and try again later."
          io.puts "If you'd like to work on your next lesson now, type: learn next"
          logger.log('ERROR: Problem parsing lesson data. Try again.')
        end
      rescue NoMethodError, Errno::ENOENT => e
        if xcodeproj_file? || xcworkspace_file?
          true
        elsif e.message.match(/for false:FalseClass/) || e.message.match(/No such file or directory/)
          false
        else
          io.puts "Sorry, there seems to be a problem with this lesson. Please submit a bug report to bugs@learn.co and try again later."
          io.puts "If you'd like to work on your next lesson now, type: learn next"
          logger.log('ERROR: Problem parsing lesson data. Try again.')
        end
      end
    end

    def open_ios_lesson
      if on_mac?
        open_xcode
      else
        io.puts "You need to be on a Mac to work on iOS lessons."
      end
    end

    def open_xcode
      if xcworkspace_file?
        system_adapter.run_command("cd #{lessons_dir}/#{lesson.name} && open *.xcworkspace")
      elsif xcodeproj_file?
        system_adapter.run_command("cd #{lessons_dir}/#{lesson.name} && open *.xcodeproj")
      end
    end

    def xcodeproj_file?
      Dir.glob("#{lessons_dir}/#{lesson.name}/*.xcodeproj").any?
    end

    def xcworkspace_file?
      Dir.glob("#{lessons_dir}/#{lesson.name}/*.xcworkspace").any?
    end

    def cd_to_lesson
      io.puts "Opening lesson..."
      system_adapter.change_context_directory("#{lessons_dir}/#{lesson.name}")
    end

    def pip_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{lesson.name}/requirements.txt")
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("python -m pip install -r requirements.txt")
      end
    end

    def jupyter_pip_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{lesson.name}/requirements.txt")
        io.puts "Installing pip dependencies..."
        system_adapter.run_command("/opt/conda/bin/python -m pip install -r requirements.txt")
      end
    end

    def bundle_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{lesson.name}/Gemfile")
        io.puts "Bundling..."
        system_adapter.run_command("bundle install")
      end
    end

    def npm_install
      if !ios_lesson? && File.exists?("#{lessons_dir}/#{lesson.name}/package.json")
        io.puts 'Installing npm dependencies...'

        if ide_environment?
          system_adapter.run_command("yarn install --no-lockfile")
        else
          system_adapter.run_command("npm install")
        end
      end
    end

    def open_readme
      if ide_environment?
        io.puts "Opening readme..."
          home_dir = "/home/#{environment_vars['CREATED_USER']}"
          File.open("#{home_dir}/.custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "browser_open", "url": "https://learn.co/lessons/#{lesson.id}"}}
        end
      elsif on_mac?
        io.puts "Opening readme..."
        launch_browser
      else
        io.puts "It looks like this lesson is a Readme. Please open it in your browser."
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
      system_adapter.run_command("open -a 'Google Chrome' https://learn.co/lessons/#{lesson.id}")
    end

    def open_safari
      system_adapter.run_command("open -a Safari https://learn.co/lessons/#{lesson.id}")
    end

    def on_mac?
      !!platform.match(/darwin/)
    end

    def github_disabled?
      !lesson.dot_learn.nil? && lesson.dot_learn[:github] == false
    end

    def ide_environment?
      environment_vars['IDE_CONTAINER'] == "true"
    end

    def ide_git_wip_enabled?
      return false if github_disabled?

      environment_vars['IDE_GIT_WIP'] == "true"
    end

    def ide_version_3?
      environment_vars['IDE_VERSION'] == "3"
    end

    def jupyter_notebook_environment?
      environment_vars['JUPYTER_CONTAINER'] == "true"
    end

    def git_tasks
    end

    def file_tasks
    end

    def dependency_tasks
      bundle_install
      npm_install
      pip_install
    end

    def restore_files
      system_adapter.spawn("restore-lab", block: true)
    end

    def watch_for_changes
      system_adapter.watch_dir("#{lessons_dir}/#{lesson.name}", "backup-lab")
    end

    def completion_tasks
      logger.log("Done.")
      io.puts "Done."
      system_adapter.open_login_shell(environment_vars['SHELL'])
    end
  end
end
