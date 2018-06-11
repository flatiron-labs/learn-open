module LearnOpen
  class Opener
    attr_accessor :repo_dir, :later_lesson, :lesson
    attr_reader :editor,
                :client,
                :lessons_dir,
                :target_lesson,
                :get_next_lesson,
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

      @options          = options
      @environment_vars = options.fetch(:environment_vars) { LearnOpen.environment_vars }
      @git_adapter      = options.fetch(:git_adapter)      { LearnOpen.git_adapter }
      @system_adapter   = options.fetch(:system_adapter)   { LearnOpen.system_adapter }
      @io               = options.fetch(:io)               { LearnOpen.default_io }
      @platform         = options.fetch(:platform)         { LearnOpen.platform }
      @logger           = options.fetch(:logger)           { LearnOpen.logger }
      @client           = options.fetch(:learn_web_client) { LearnOpen.learn_web_client }

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
      io.puts "Looking for lesson..."
      Lessons.classify(lesson_data, options).open(lessons_dir, editor)
    end

    private

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
  end
end
