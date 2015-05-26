module LearnOpen
  class Opener
    attr_reader :lesson, :editor, :client

    def self.run(lesson:, editor_specified:)
      new(lesson, editor_specified).run
    end

    def initialize(lesson, editor)
      _login, token = Netrc.read['learn-config']
      @client  = LearnWeb::Client.new(token: token)

      @lesson = lesson
      @editor = editor
    end

    def run
      if !lesson
        lesson = get_current_lesson
        puts editor
        puts lesson
        exit
      end
      # if !lesson, get current lesson path from api
      # if lesson, get correct lesson path from api
      #   clone
      #   cd
      #
      # if editor
      #   if binary exists
      #     open with binary
    end

    private

    def get_current_lesson
      client.current_lesson.github_repo
    end
  end
end
