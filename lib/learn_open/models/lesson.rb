module LearnOpen
  class Lesson
    attr_reader :repo_path,
      :id,
      :dot_learn,
      :name,
      :organization

    def initialize(lesson_data)
      lesson = lesson_data[:lesson]

      @repo_path           = lesson.clone_repo
      @organization, @name = repo_path.split('/')
      @is_lab              = lesson.lab
      @id                  = lesson.lesson_id
      @dot_learn           = Hash(lesson.dot_learn)
      @is_later_lesson     = lesson_data[:later_lesson]
    end

    def later_lesson?
      @is_later_lesson
    end

    def lab?
      @is_lab
    end

    def readme?
      !lab?
    end

    def github_disabled?
      dot_learn[:github] == false
    end
  end
end
