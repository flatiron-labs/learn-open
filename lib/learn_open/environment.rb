module LearnOpen
  module Environment
    # IDE
    def self.ide?
      ENV['IDE_CONTAINER'] == "true"
    end

    # IDE 3
    def self.valid?(lesson)
      return true unless ide_version_3?
      requires_new_environment?(lesson)
    end

    # Shell? All
    def self.warn_skipping_lessons
      puts 'WARNING: You are attempting to open a lesson that is beyond your current lesson.'
      print 'Are you sure you want to continue? [Yn]: '

      warn_response = STDIN.gets.chomp.downcase
      exit if !['yes', 'y'].include?(warn_response)
    end


    # IDE 3
    def self.open(lesson)
      if ide_version_3?
        File.open("#{home_dir}/.custom_commands.log", "a") do |f|
          f.puts %Q{{"command": "open_lab", "lab_name": "#{lesson.name}"}}
        end
      end
    end

    # IDE 3
    def self.ide_v3_open_browser(lesson_url)
      File.open(".custom_commands.log", "a") do |f|
        f.puts %Q{{"command": "browser_open", "url": lesson_url}}
      end
    end

    # IDE 3, IDE Legacy, Mac(chrome, safari)
    def self.open_browser(id)
      lesson_url = "https://learn.co/lessons/#{id}"
      if ide?
        ide_v3_open_browser(lesson_url)
      elsif mac?
        if chrome_installed?
          system("open -a 'Google Chrome' #{lesson_url}")
        else
          system("open -a Safari #{lesson_url}")
        end
      end
    end

    # IDE 3
    def self.requires_new_environment?(lesson)
      lesson.name != ide_lab_name
    end

    # IDE 3
    def self.ide_lab_name
      ENV['LAB_NAME']
    end

    # Factory
    def self.ide_version_3?
      ENV['IDE_VERSION'] == "3"
    end

    # IDE 3 Jupyter?
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

    # all
    def self.lessons_dir
      YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
    end

    # all
    def self.lesson_dir(lesson_name)
      "#{lessons_dir}/#{lesson_name}"
    end

    # all
    def self.lesson_files(lesson_name)
      Dir.glob("#{lesson_dir(lesson_name)}/**/*")
    end
  end
end
