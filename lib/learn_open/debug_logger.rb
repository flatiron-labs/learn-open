module LearnOpen
  class DebugLogger
    attr_reader :file_path
    def initialize(file_path)
      @file_path = file_path
      FileUtils.touch(file_path)
      File.write(file_path, '')
    end

    def log_fetch_current_lesson(status)
      binding.pry
      case status
      when :retrying
        puts "There was a problem getting your lesson from Learn. Retrying..."
      when :retries_exceeded
        puts "There seems to be a problem connecting to Learn. Please try again."
        File.write(file_path, 'ERROR: Error connecting to Learn')
        exit
      end
    end

    def log_fetch_next_lesson(status)
      case status
      when :retrying
        puts "There was a problem getting your next lesson from Learn. Retrying..."
      when :retries_exceeded
        puts "There seems to be a problem connecting to Learn. Please try again."
        File.write(file_path, 'ERROR: Error connecting to Learn')
        exit
      end
    end

    def log_fetch_lesson(status)
      case status
      when :retrying
        puts "There was a problem connecting to Learn. Retrying..."
      when :retries_exceeded
        puts "Cannot connect to Learn right now. Please try again."
        File.write(file_path, 'ERROR: Error connecting to Learn')
        exit
      end
    end

    def log_fork_repo(status)
      case status
      when :starting, :fake_starting
        File.write(file_path, 'Forking repository...')
        puts "Forking lesson..."
      when :retrying
        puts "There was a problem forking this lesson. Retrying..."
      when :retries_exceeded
        puts "There is an issue connecting to Learn. Please try again."
        File.write(file_path, 'ERROR: Error connecting to Learn')
        exit
      end
    end

    def log_clone_repo(status)
      case status
      when :start
        File.write(file_path, 'Cloning to your machine...')
        puts "Cloning lesson..."
      when :retrying
        puts "There was a problem cloning this lesson. Retrying..."
      when :retries_exceeded
        puts "Cannot clone this lesson right now. Please try again."
        File.write(file_path, 'ERROR: Error cloning. Try again.')
        exit
      end
    end

    def log_ping_fork_completion(status)
      case status
      when :retrying
        puts "There was a problem forking and cloning this lesson. Retrying..."
      when :retries_exceeded
        puts "There is an issue connecting to Learn. Please try again."
        File.write(file_path, 'ERROR: Error connecting to Learn')
        exit
      end
    end

    def log_getting_lesson
      File.write(file_path, 'Getting lesson...')
      puts "Looking for lesson..."
    end

    def log_done
      File.write(file_path, 'Done.')
      puts "Done."
    end
  end
end
