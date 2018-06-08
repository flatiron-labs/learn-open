module LearnOpen
  module LessonDownloader
    def self.call(lesson, location)
      if !repo_exists?(lesson, location)
        fork_repo(lesson)
        clone_repo(lesson, location)
      else
        :noop
      end
    end

    def self.client
      LearnOpen.learn_web_client
    end

    def self.logger
      LearnOpen.logger
    end

    def self.fork_repo(lesson, retries=3)
      io = Kernel
      logger.log('Forking repository...')
      io.puts "Forking lesson..."

      if !github_disabled?(lesson)
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

    def clone_repo(lesson, location, retries=3)
      logger.log('Cloning to your machine...')
      io.puts "Cloning lesson..."
      begin
        Timeout::timeout(15) do
          git_adapter.clone("git@github.com:#{lesson.repo_path}.git", lesson.name, path: location)
        end
      rescue Git::GitExecuteError
        if retries > 0
          io.puts "There was a problem cloning this lesson. Retrying..." if retries > 1
          sleep(1)
          clone_repo(lesson, location, retries-1)
        else
          io.puts "Cannot clone this lesson right now. Please try again."
          logger.log('ERROR: Error cloning. Try again.')
          exit
        end
      rescue Timeout::Error
        if retries > 0
          io.puts "There was a problem cloning this lesson. Retrying..."
          clone_repo(lesson, location, retries-1)
        else
          io.puts "Cannot clone this lesson right now. Please try again."
          logger.log('ERROR: Error cloning. Try again.')
          exit
        end
      end
      if github_disabled?(lesson)
        ping_fork_completion
      end
    end

    def self.repo_exists?(lesson, location)
      File.exists?("#{location}/#{lesson.name}/.git")
    end
    def self.github_disabled?(lesson)
      lesson.dot_learn[:github] == false
    end
  end
end
