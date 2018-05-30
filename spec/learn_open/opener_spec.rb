require 'spec_helper'
require 'fakefs/spec_helpers'
require 'pry'

describe LearnOpen::Opener do
  include FakeFS::SpecHelpers
  let(:learn_client_class)     { class_double(LearnWeb::Client) }
  let(:learn_client_double)    { FakeLearnClient.new }
  let(:git_adapter)            { FakeGit.new }
  let(:system_adapter)         { class_double(LearnOpen::SystemAdapter) }

  before do
    create_home_dir
    create_netrc_file
    create_learn_config_file
  end

  context "asking for a specific lesson" do
    it "sets the lesson" do
      opener = LearnOpen::Opener.new("ttt-2-board-rb-v-000","", false)
      expect(opener.lesson).to eq("ttt-2-board-rb-v-000")
    end
  end

  context "setting specific editor" do
    it "sets the editor" do
      opener = LearnOpen::Opener.new("", "atom", false)
      expect(opener.editor).to eq("atom")
    end
  end

  context "asking for next lesson" do
    it "sets the whether to open the next lesson or not" do
      opener = LearnOpen::Opener.new("", "", true)
      expect(opener.get_next_lesson).to eq(true)
    end
  end

  it "reads the token from the .netrc file" do
    opener = LearnOpen::Opener.new("", "", "")
    expect(opener.token).to eq("some-amazing-password")
  end

  it "loads lesson directory from learn-config" do
    opener = LearnOpen::Opener.new("", "", "", learn_client_class: spy)
    expect(opener.file_path).to eq("#{home_dir}/.learn-open-tmp")
  end

  context "running the opener" do
    it "calls its collaborators" do
      expect(system_adapter)
        .to receive(:open_editor)
        .with("atom", path: ".")

      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/bin/fish")

      expect(learn_client_double)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      expect(learn_client_class).to receive(:new)
        .with(token: "some-amazing-password")
        .and_return(learn_client_double)

      opener = LearnOpen::Opener.new(nil, "atom", true,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
																		 environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter)
      opener.run
    end
    it "sets values of next lesson from client payload" do
      allow(system_adapter).to receive(:open_editor)
      allow(system_adapter).to receive(:open_login_shell)
      allow(learn_client_double).to receive(:fork_repo)
      allow(learn_client_class).to receive(:new).and_return(learn_client_double)

      opener = LearnOpen::Opener.new(nil, "atom", true,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
																		 environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter)
      opener.run
      expect(opener.lesson).to eq("StevenNunez/rails-dynamic-request-lab-cb-000")
      expect(opener.lesson_is_lab).to eq(true)
      expect(opener.later_lesson).to eq(false)
      expect(opener.dot_learn).to eq({:tags=>["dynamic routes", "controllers", "rspec", "capybara", "mvc"], :languages=>["ruby"], :type=>["lab"], :resources=>2})
    end

    it "opens the current lesson" do
      allow(system_adapter).to receive(:open_editor)
      allow(system_adapter).to receive(:open_login_shell)
      allow(learn_client_double).to receive(:fork_repo)
      allow(learn_client_class).to receive(:new).and_return(learn_client_double)

      opener = LearnOpen::Opener.new(nil, "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
																		 environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter)
      opener.run
      expect(opener.lesson).to eq("StevenNunez/ttt-2-board-rb-v-000")
      expect(opener.lesson_is_lab).to eq(true)
      expect(opener.later_lesson).to eq(false)
      expect(opener.dot_learn).to eq({:tags=>["variables", "arrays", "tictactoe"], :languages=>["ruby"], :resources=>0})
    end
    # if the directory exists, don't clone
    # github_disabled stuff
  end
  context "Opening on specific environments" do
    before do
      allow(system_adapter).to receive(:open_editor)
      allow(system_adapter).to receive(:open_login_shell)
      allow(learn_client_double).to receive(:fork_repo)
      allow(learn_client_class).to receive(:new).and_return(learn_client_double)
    end
    context "IDE" do
      it "does not write to the custom commands log if environment is for intended lab" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "rails-dynamic-request-lab-cb-000",
          "CREATED_USER" => "bobby",
          "IDE_VERSION" => "3"
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_adapter: environment,
                                       system_adapter: system_adapter)
        opener.run
        expect(File.exist?("#{home_dir}/.custom_commands.log")).to eq(false)
      end

      it "writes to custom_commands_log if lab name doesn't match env" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "Something wild",
          "CREATED_USER" => "bobby",
          "IDE_VERSION" => "3"
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_adapter: environment,
                                       system_adapter: system_adapter)
        opener.run
        custom_commands_log = File.read("#{home_dir}/.custom_commands.log")
        expect(custom_commands_log).to eq("{\"command\": \"open_lab\", \"lab_name\": \"rails-dynamic-request-lab-cb-000\"}\n")
      end

      it "writes to custom_commands_log if only if it's IDE v3" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "Something wild",
          "CREATED_USER" => "bobby",
          "IDE_VERSION" => "2"
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_adapter: environment,
                                       system_adapter: system_adapter)
        opener.run
        expect(File.exist?("#{home_dir}/.custom_commands.log")).to eq(false)
      end
    end
    # on IDE
    # on mac
    #   with chrome
    # jupyter lab
    #   pip install
    # jupyter readme
    # readme
    # lab
    #   Maybe bundle, pip, ios
  end
end

=begin
Things to test
Current Lesson
Logging
Setting the "lesson" we're going to be opening
  name passed in? asked for next? Nothing passed in?
Most tests for IOS and jupter will be where we explicitly pass in a lesson name that's setup to be IOS/jupyter-y
=end

