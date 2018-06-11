module LearnOpen
  module Lessons

    def self.default
      LabLesson
    end

    def self.lesson_types
      [
        JupyterLesson,
        GithubDisabledLesson,
        ReadmeLesson,
        IosLesson,

      ]
    end
    def self.classify(lesson_data, options={})
      dot_learn = Hash(lesson_data[:lesson][:dot_learn])
      default = method(:default)
      lesson_types.find(default) do |type|
        type.detect(dot_learn)
      end.new(lesson_data, options)
    end
  end
end
