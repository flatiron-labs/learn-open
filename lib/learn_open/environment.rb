module LearnOpen
  module Environment
    def self.ide?
      ENV['IDE_CONTAINER'] == "true"
    end

    def self.valid?(lesson)
      return true unless ide_version_3?
      requires_new_environment?(lesson)
    end

    def self.open(lesson)
      if ide_version_3?
        File.open("#{home_dir}/.custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
        end
      end
    end

    def self.requires_new_environment?(lesson)
      lesson.name != ide_lab_name
    end

    def self.ide_lab_name
      ENV['LAB_NAME']
    end

    def self.ide_version_3?
      ENV['IDE_VERSION'] == "3"
    end

    def self.ide_git_wip_enabled?
      ENV['IDE_GIT_WIP'] == "true"
    end

    def self.home_dir
      File.expand_path("~")
    end

    def self.ide_v3?
      ENV['IDE_VERSION'] == "3"
    end

    def self.managed_jupyter_environment?
      ENV['JUPYTER_CONTAINER'] == "true"
    end

    def self.mac?
      !!RUBY_PLATFORM.match(/darwin/)
    end

    def self.lessons_dir
      YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
    end

    def self.lesson_dir(lesson_name)
      "#{lessons_dir}/#{lesson_name}"
    end

    def self.lesson_files(lesson_name)
      Dir.glob("#{lesson_dir(lesson_name)}/**/*")
    end
  end
end
