module LearnOpen
  class Opener
    attr_accessor :repo_path, :repo_dir
    attr_reader :editor,
                :client,
                :lessons_dir,
                :target_lesson,
                :get_next_lesson,
                :token,
                :environment_adapter,
                :git_adapter,
                :system_adapter,
                :io,
                :platform,
                :lesson,
                :logger

    def self.run(lesson:, editor_specified:, get_next_lesson:)
      new(lesson, editor_specified, get_next_lesson).run
    end

    def initialize(target_lesson, editor, get_next_lesson, learn_client_class: LearnWeb::Client, file_system_adapter: FileUtils, environment_adapter: ENV, git_adapter: Git, system_adapter: SystemAdapter, io: Kernel, platform: RUBY_PLATFORM)
      @target_lesson   = target_lesson
      @editor          = editor
      @get_next_lesson = get_next_lesson

      @file_system_adapter = file_system_adapter
      @environment_adapter = environment_adapter
      @git_adapter         = git_adapter
      @system_adapter      = system_adapter
      @io                  = io
      @platform            = platform


      home_dir         = File.expand_path("~")
      netrc_path     ||= "#{home_dir}/.netrc"
      _login, @token   = Netrc.read['learn-config']
      @client          = learn_client_class.new(token: @token)
      @lessons_dir     = YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
      @logger          = Logger.new( "#{home_dir}/.learn-open-tmp")
    end


    def run
      logger.log('Getting lesson...')

      lesson_data = if !target_lesson && !get_next_lesson
        load_current_lesson
        {lesson: current_lesson, later_lesson: false}
      elsif !target_lesson && get_next_lesson
        load_next_lesson
        {lesson: next_lesson, later_lesson: false}
      else
        {lesson: correct_lesson, later_lesson: correct_lesson.later_lesson}
      end

      @lesson = Lesson.new(lesson_data)
      @learning_environment = LearningEnvironments.get(
        environment_adapter,
        platform,
        client,
        lessons_dir,
        logger,
        io,
        git_adapter,
        system_adapter
      )

      result = @learning_environment.open(lesson)
      return if result == false #temporary until we get the other environments written

      io.puts "Looking for lesson..."
      if jupyter_notebook_environment?
        git_tasks
        file_tasks
        restore_files
        watch_for_changes
        jupyter_pip_install
        completion_tasks
      else
        warn_if_necessary
        if lesson.readme?
          open_readme
        else
          git_tasks
          file_tasks
          setup_backup_if_needed
          dependency_tasks
          completion_tasks
        end
      end
    end

    def repo_exists?
      File.exists?("#{lessons_dir}/#{lesson.name}/.git")
    end

    private
    attr_reader :file_system_adapter

    def setup_backup_if_needed
      if ide_environment? && ide_git_wip_enabled?
        restore_files
        watch_for_changes
      end
    end

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

      if lesson.later_lesson?
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

    def cleanup_tmp_file
      logger.log('Done.')
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

        if !lesson.github_disabled?
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

      if lesson.github_disabled?
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
        languages   = YAML.load(File.read("#{lessons_dir}/#{repo_dir}/.learn"))['languages']
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
          home_dir = "/home/#{environment_adapter['CREATED_USER']}"
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

    def ide_environment?
      environment_adapter['IDE_CONTAINER'] == "true"
    end

    def ide_git_wip_enabled?
      return false if lesson.github_disabled?

      environment_adapter['IDE_GIT_WIP'] == "true"
    end

    def ide_version_3?
      environment_adapter['IDE_VERSION'] == "3"
    end

    def jupyter_notebook_environment?
      environment_adapter['JUPYTER_CONTAINER'] == "true"
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
      pip_install
    end

    def restore_files
      system_adapter.spawn("restore-lab", block: true)
    end

    def watch_for_changes
      system_adapter.watch_dir("#{lessons_dir}/#{lesson.name}", "backup-lab")
    end

    def completion_tasks
      cleanup_tmp_file
      io.puts "Done."
      system_adapter.open_login_shell(environment_adapter['SHELL'])
    end
  end
end
