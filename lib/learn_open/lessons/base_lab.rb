module LearnOpen
  module Lessons
    class BaseLab < BaseLesson
      attr_reader :editor, :client
      def initialize(lesson_data, editor:, client:, logger:, environment: Environment)
        super(lesson_data, environment: environment, logger: logger)
        @editor = editor
        @client = client
      end

      def git_tasks
        fork_repo
        clone_repo(full_path, environment.lessons_dir)
      end

      def file_tasks
        cd_to_lesson
        open_with_editor
      end

      def fork_repo
        if !repo_exists?
          if github_disabled?
            fake_github_fork
          else
            client.fork_repo(name, &logger.method(:log_fork_repo))
          end
        end
      end

      def clone_repo
        if !repo_exists?
          client.clone_repo(full_path, name, &logger.method(:log_clone_repo))
        end
        if github_disabled?
          client.ping_fork_completion(org_name, name, &logger.method(:log_ping_fork_completion))
        end
      end

      def cd_to_lesson
        puts "Opening lesson..."
        Dir.chdir("#{environment.lessons_dir}/#{name}")
      end

      def open_with_editor
        if ios_lesson?
          open_ios_lesson
        elsif editor
          system("#{editor} .")
        end
      end

      # Don't love this
      def dependency_tasks
        bundle_install
        npm_install
        pip_install
      end

      def pip_install
        if File.exists?("#{environment.lesson_dir(name)}/requirements.txt")
          puts "Installing pip dependencies..."
          system("pip install -r requirements.txt")
        end
      end

      def bundle_install
        if File.exists?("#{environment.lesson_dir(name)}/Gemfile")
          puts "Bundling..."
          system("bundle install")
        end
      end

      def npm_install
        if File.exists?("#{environment.lesson_dir(name)}/package.json")
          puts 'Installing npm dependencies...'

          if ide_environment?
            system("yarn install --no-lockfile")
          else
            system("npm install")
          end
        end
      end
      def completion_tasks
        logger.log_done
        exec("#{ENV['SHELL']} -l")
      end
    end
  end
end
