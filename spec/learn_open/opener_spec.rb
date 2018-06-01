require 'spec_helper'
require 'fakefs/spec_helpers'
require 'pry'

describe LearnOpen::Opener do
  include FakeFS::SpecHelpers
  let(:learn_client_class)     { FakeLearnClient }
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
        .to receive_messages(
      open_login_shell: "/usr/local/bin/fish",
      change_context_directory: "/home/bobby/Development/code/jupyter_lab")

      expect_any_instance_of(learn_client_class)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      opener = LearnOpen::Opener.new(nil, "atom", true,
                                     learn_client_class: FakeLearnClient,
                                     git_adapter: git_adapter,
                                     environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
    end
    it "sets values of next lesson from client payload" do
      allow(system_adapter)
        .to receive_messages(
      open_editor: :noop,
      open_login_shell: :noop,
      change_context_directory: :noop
      )
      allow_any_instance_of(learn_client_class).to receive(:fork_repo)

      opener = LearnOpen::Opener.new(nil, "atom", true,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
      expect(opener.lesson).to eq("StevenNunez/rails-dynamic-request-lab-cb-000")
      expect(opener.lesson_is_lab).to eq(true)
      expect(opener.later_lesson).to eq(false)
      expect(opener.dot_learn).to eq({:tags=>["dynamic routes", "controllers", "rspec", "capybara", "mvc"], :languages=>["ruby"], :type=>["lab"], :resources=>2})
    end

    it "opens the current lesson" do
      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop
      )
      allow_any_instance_of(learn_client_class).to receive(:fork_repo)

      opener = LearnOpen::Opener.new(nil, "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_adapter: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     io: spy)
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
      allow(system_adapter).to receive_messages(
        open_editor: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop
      )
      allow_any_instance_of(learn_client_class).to receive(:fork_repo)
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
                                       system_adapter: system_adapter,
                                       io: spy)
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
                                       system_adapter: system_adapter,
                                       io: spy)
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
                                       system_adapter: system_adapter,
                                       io: spy)
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
    # Test messages printed on screen
  end
  context "Logging" do
    let(:environment) {{ "SHELL" => "/usr/local/bin/fish", "JUPYTER_CONTAINER" => "true" }}
    it "prints the right things" do
      allow_any_instance_of(learn_client_class).to receive(:fork_repo)

      allow(git_adapter).to receive(:clone).and_call_original

      allow(system_adapter).to receive_messages(
        open_editor: nil,
        spawn: nil,
        watch_dir: nil,
        open_login_shell: nil,
        change_context_directory: nil,
        run_command: nil,
      )

      io = StringIO.new

      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_adapter: environment,
                                     system_adapter: system_adapter,
                                     io: io)
      opener.run
      io.rewind
      expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Installing pip dependencies...
Done.
      EOF
    end

    it "logs final status in file" do
      allow_any_instance_of(learn_client_class).to receive(:fork_repo)

      allow(git_adapter).to receive(:clone).and_call_original

      allow(system_adapter).to receive_messages(
        open_editor: nil,
        spawn: nil,
        watch_dir: nil,
        open_login_shell: nil,
        change_context_directory: nil,
        run_command: nil,
      )


      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_adapter: environment,
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
      expect(File.read("#{home_dir}/.learn-open-tmp")).to eq("Done.")
    end
  end
  context "Lab Types" do
    context "Jupyter Labs" do
      let(:environment) {{ "SHELL" => "/usr/local/bin/fish", "JUPYTER_CONTAINER" => "true" }}

      it "correctly opens jupter lab" do
        expect_any_instance_of(learn_client_class)
          .to receive(:fork_repo)
          .with(repo_name: "jupyter_lab")

        expect(git_adapter)
          .to receive(:clone)
          .with("git@github.com:StevenNunez/jupyter_lab.git", "jupyter_lab", {:path=>"/home/bobby/Development/code"})
          .and_call_original

        expect(system_adapter)
          .to receive_messages(
        open_editor: ["atom", {:path=>"."}],
        spawn: ["restore-lab", {:block=>true}],
        watch_dir: ["/home/bobby/Development/code/jupyter_lab", "backup-lab"],
        open_login_shell: "/usr/local/bin/fish",
        change_context_directory: "/home/bobby/Development/code/jupyter_lab",
        run_command: "/opt/conda/bin/python -m pip install -r requirements.txt",

        )

        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_adapter: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
      end
    end
    context "Labs"
    context "Readme" do
      let(:environment) {{ "SHELL" => "/usr/local/bin/fish"}}
      it "opens them in the browser if possible" do
        expect_any_instance_of(learn_client_class)
          .to receive(:fork_repo)
          .with(repo_name: "jupyter_lab")

        expect(git_adapter)
          .to receive(:clone)
          .with("git@github.com:StevenNunez/jupyter_lab.git", "jupyter_lab", {:path=>"/home/bobby/Development/code"})
          .and_call_original

        expect(system_adapter)
          .to receive_messages(
        open_editor: ["atom", {:path=>"."}],
        spawn: ["restore-lab", {:block=>true}],
        watch_dir: ["/home/bobby/Development/code/jupyter_lab", "backup-lab"],
        open_login_shell: "/usr/local/bin/fish",
        change_context_directory: "/home/bobby/Development/code/jupyter_lab",
        run_command: "/opt/conda/bin/python -m pip install -r requirements.txt",

        )

        opener = LearnOpen::Opener.new("readme", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_adapter: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
      end
    end
  end
end

=begin
Things to test
Current Lesson
Setting the "lesson" we're going to be opening
  name passed in? asked for next? Nothing passed in?
Most tests for IOS and jupter will be where we explicitly pass in a lesson name that's setup to be IOS/jupyter-y
=end

