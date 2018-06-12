require 'yaml'
require 'netrc'
require 'git'
require 'learn_web'
require 'timeout'

require 'learn_open/version'
require 'learn_open/opener'
require 'learn_open/logger'
require 'learn_open/argument_parser'
require 'learn_open/adapters/system_adapter'
require 'learn_open/adapters/learn_web_adapter'
require 'learn_open/environments/base_environment'
require 'learn_open/environments/mac_environment'
require 'learn_open/environments/generic_environment'
require 'learn_open/environments/ide_environment'
require 'learn_open/environments/jupyter_container_environment'
require 'learn_open/environments'
require 'learn_open/services/lesson_downloader'
require 'learn_open/services/file_backup_starter'
require 'learn_open/services/dependency_installer'
require 'learn_open/services/logger'
require 'learn_open/lessons'
require 'learn_open/lessons/base_lesson'
require 'learn_open/lessons/jupyter_lesson'
require 'learn_open/lessons/readme_lesson'
require 'learn_open/lessons/ios_lesson'
require 'learn_open/lessons/lab_lesson'

module LearnOpen
  def self.learn_web_client
    @client ||= begin
                  _login, token = Netrc.read['learn-config']
                  client        = LearnWeb::Client.new(token: token)
                end
  end

  def self.logger
    @logger ||= begin
                  home_dir = File.expand_path("~")
                  Logger.new("#{home_dir}/.learn-open-tmp")
                end
  end

  def self.default_io
    Kernel
  end

  def self.git_adapter
    Git
  end

  def self.environment_vars
    ENV
  end

  def self.system_adapter
    LearnOpen::Adapters::SystemAdapter
  end

  def self.platform
    RUBY_PLATFORM
  end

  def self.lessons_directory
    @lesson_directory ||= begin
                            home_dir = File.expand_path("~")
                            YAML.load(File.read("#{home_dir}/.learn-config"))[:learn_directory]
                          end
  end
end
