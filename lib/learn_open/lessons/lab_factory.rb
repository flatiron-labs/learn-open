module LearnOpen
  module Lessons
    class LabFactory
      def self.generic_lab
        GenericLab
      end

      def self.lab_types
        [
          IosLab,
          JupyterLab,
          GithubDisabledLab,
          GenericLab,
        ]
      end

      def self.get(lesson_data, editor:, client:, environment:, logger:)
        default = method(:generic_lab)
        lab_type = lab_types.find(default) {|lab| lab.detect(lesson_data, environment)}
        lab_type.new(lesson_data, 
                     editor: editor, 
                     client: client, 
                     environment: environment, 
                     logger: logger)
      end
    end
  end
end
