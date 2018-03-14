module LearnOpen
  module Lessons
    class LabFactory
      def self.get(lesson_data, editor:, client:, environment: Environment, logger:)
        if ios_lab?(lesson_data, environment)
          IosLab.new(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
        elsif jupyter_notebook_lab?(lesson_data, environment)
          JupyterLab.new(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
        elsif github_disabled_lab?(lesson_data, environment)
          GithubDisabledLab.new(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
        else
          GenericLab.new(lesson_data, editor: editor, client: client, environment: environment, logger: logger)
        end
      end

      def self.ios_lab?(lesson_data, environment)
        languages   = lesson_data
                      .fetch(:dot_learn, {})
                      .fetch(:languages, [])
        ios_lang    = languages.any? {|l| ['objc', 'swift'].include?(l)}

        !!(ios_lang || xcodeproj_file?(lesson_data, environment) || xcworkspace_file?(lesson_data, environment))
      end

      def self.github_disabled_lab?(lesson_data, environment)
        Hash(lesson_data[:dot_learn])[:github] == false
      end

      def self.jupyter_notebook_lab?(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? {|file| file.end_with?("ipynb")}
      end

      def self.xcworkspace_file?(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? do |file|
          file.end_with?("xcworkspace")
        end
      end

      def self.xcodeproj_file?(lesson_data, environment)
        environment.lesson_files(lesson_data[:repo_name]).any? do |file|
          file.end_with?("xcodeproj")
        end
      end
    end
  end
end
