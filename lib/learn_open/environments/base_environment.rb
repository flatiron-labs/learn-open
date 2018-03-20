module LearnOpen
  module Environments
    class BaseEnvironment
      def valid?(_lesson); true; end
      def open(_lesson); nil; end
      def open_brower(_id); nil; end
      def lessons_dir
        YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
      end

      def lesson_dir(lesson_name)
        "#{lessons_dir}/#{lesson_name}"
      end

      def lesson_files(lesson_name)
        Dir.glob("#{lesson_dir(lesson_name)}/**/*")
      end

      def home_dir
        File.expand_path("~")
      end
    end
  end
end
