module LearnOpen
  module LearningEnvironments
    class IDEv3
      attr_reader :environment_adapter, :platform, :client, :lessons_dir
      def initialize(environment_adapter, platform, client, lessons_dir)
        @environment_adapter = environment_adapter
        @platform            = platform
        @client              = client
        @lessons_dir         = lessons_dir
      end
      def open(lesson)
        if lesson.name != environment_adapter['LAB_NAME']
          home_dir = "/home/#{environment_adapter['CREATED_USER']}"
          File.open("#{home_dir}/.custom_commands.log", "a") do |f|
            f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
          end
          false
        else
          true
        end
      end
    end
  end
end
