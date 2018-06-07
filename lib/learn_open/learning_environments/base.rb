module LearnOpen
  module LearningEnvironments
    class Base
      attr_reader :environment_adapter,
        :platform,
        :client,
        :lessons_dir,
        :logger,
        :io,
        :git_adapter,
        :system_adapter

      def initialize(environment_adapter, platform, client, lessons_dir, logger, io, git_adapter, system_adapter)
        @environment_adapter = environment_adapter
        @platform            = platform
        @client              = client
        @lessons_dir         = lessons_dir
        @logger              = logger
        @io                  = io
        @git_adapter         = git_adapter
        @system_adapter      = system_adapter
      end

      def clone_repo(lesson, retries=3)
        if !repo_exists?(lesson)
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
              clone_repo(lesson, retries-1)
            else
              io.puts "Cannot clone this lesson right now. Please try again."
              logger.log('ERROR: Error cloning. Try again.')
              exit
            end
          rescue Timeout::Error
            if retries > 0
              io.puts "There was a problem cloning this lesson. Retrying..."
              clone_repo(lesson, retries-1)
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

      def git_tasks(lesson)
        fork_repo(lesson)
        clone_repo(lesson)
      end

      def repo_exists?(lesson)
        File.exists?("#{lessons_dir}/#{lesson.name}/.git")
      end

      def fork_repo(lesson, retries=3)
        if !repo_exists?(lesson)
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
                fork_repo(lesson, retries-1)
              else
                io.puts "There is an issue connecting to Learn. Please try again."
                logger.log('ERROR: Error connecting to Learn')
                exit
              end
            end
          end
        end
      end
      def file_tasks(lesson)
        cd_to_lesson(lesson)
        open_with_editor
      end
      def cd_to_lesson(lesson)
        io.puts "Opening lesson..."
        system_adapter.change_context_directory("#{lessons_dir}/#{lesson.name}")
      end

    end
  end
end
