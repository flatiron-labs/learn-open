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

  context "Initializer" do
    it "sets the lesson" do
      opener = LearnOpen::Opener.new("ttt-2-board-rb-v-000","", false)
      expect(opener.target_lesson).to eq("ttt-2-board-rb-v-000")
    end
    it "sets the editor" do
      opener = LearnOpen::Opener.new("", "atom", false)
      expect(opener.editor).to eq("atom")
    end
    it "sets the whether to open the next lesson or not" do
      opener = LearnOpen::Opener.new("", "", true)
      expect(opener.get_next_lesson).to eq(true)
    end

    it "reads the token from the .netrc file" do
      opener = LearnOpen::Opener.new("", "", "")
      expect(opener.token).to eq("some-amazing-password")
    end
  end

  context "running the opener" do
    it "calls its collaborators" do
      expect(system_adapter)
        .to receive(:open_editor)
        .with("atom", path: ".")

      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/bin/fish")

      expect(system_adapter)
        .to receive(:change_context_directory)
        .with("/home/bobby/Development/code/rails-dynamic-request-lab-cb-000")

      expect_any_instance_of(learn_client_class)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      opener = LearnOpen::Opener.new(nil, "atom", true,
                                     learn_client_class: FakeLearnClient,
                                     git_adapter: git_adapter,
                                     environment_vars: {"SHELL" => "/usr/local/bin/fish"},
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
                                     environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
      expect(opener.lesson.repo_path).to eq("StevenNunez/rails-dynamic-request-lab-cb-000")
      expect(opener.lesson.later_lesson).to eq(false)
      expect(opener.lesson.dot_learn).to eq({:tags=>["dynamic routes", "controllers", "rspec", "capybara", "mvc"], :languages=>["ruby"], :type=>["lab"], :resources=>2})
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
                                     environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
      expect(opener.lesson.repo_path).to eq("StevenNunez/ttt-2-board-rb-v-000")
      expect(opener.lesson.later_lesson).to eq(false)
      expect(opener.lesson.dot_learn).to eq({:tags=>["variables", "arrays", "tictactoe"], :languages=>["ruby"], :resources=>0})
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
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
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
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
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
          "IDE_CONTAINER" => "true",
        }

        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new(nil, "atom", true,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
        expect(File.exist?("#{home_dir}/.custom_commands.log")).to eq(false)
      end

      it "restores files and watches for changes when git wip enabled" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "ruby_lab",
          "IDE_GIT_WIP" => "true",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
          "IDE_VERSION" => "3"
        }

        create_linux_home_dir("bobby")
        expect(system_adapter)
          .to receive(:spawn)
          .with('restore-lab', block: true)
        expect(system_adapter)
          .to receive(:watch_dir)
          .with("/home/bobby/Development/code/ruby_lab", "backup-lab")
        expect(system_adapter)
          .to receive(:run_command)
          .with("bundle install")

        opener = LearnOpen::Opener.new("ruby_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
      end
      it "runs yarn install if lab is a node lab" do
        environment = {
          "SHELL" => "/usr/local/bin/fish",
          "LAB_NAME" => "python_lab",
          "CREATED_USER" => "bobby",
          "IDE_CONTAINER" => "true",
        }
        expect(system_adapter)
          .to receive(:open_editor)
          .with("atom", path: ".")

        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")

        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/node_lab")

        expect(system_adapter)
          .to receive(:run_command)
          .with("yarn install --no-lockfile")

        opener = LearnOpen::Opener.new("node_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
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
        open_editor: :noop,
        spawn: :noop,
        watch_dir: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop,
        run_command: :noop,
      )

      io = StringIO.new

      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_vars: environment,
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
        open_editor: :noop,
        spawn: :noop,
        watch_dir: :noop,
        open_login_shell: :noop,
        change_context_directory: :noop,
        run_command: :noop,
      )


      opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                     learn_client_class: learn_client_class,
                                     git_adapter: git_adapter,
                                     environment_vars: environment,
                                     system_adapter: system_adapter,
                                     io: spy)
      opener.run
      expect(File.read("#{home_dir}/.learn-open-tmp")).to eq("Done.")
    end
  end
  context "Lab Types" do
    context "Jupyter Labs" do
      let(:environment) {{ "SHELL" => "/usr/local/bin/fish", "JUPYTER_CONTAINER" => "true" }}

      it "correctly opens jupyter lab" do
        expect_any_instance_of(learn_client_class)
          .to receive(:fork_repo)
          .with(repo_name: "jupyter_lab")

        expect(git_adapter)
          .to receive(:clone)
          .with("git@github.com:StevenNunez/jupyter_lab.git", "jupyter_lab", {:path=>"/home/bobby/Development/code"})
          .and_call_original

        expect(system_adapter)
          .to receive(:open_editor)
          .with("atom", path: ".")
        expect(system_adapter)
          .to receive(:spawn)
          .with("restore-lab", block: true)
        expect(system_adapter)
          .to receive(:watch_dir)
          .with("/home/bobby/Development/code/jupyter_lab", "backup-lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/jupyter_lab")
        expect(system_adapter)
          .to receive(:run_command)
          .with("/opt/conda/bin/python -m pip install -r requirements.txt")

        opener = LearnOpen::Opener.new("jupyter_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       io: spy)
        opener.run
      end
    end
    context "Readme" do
      it "does not open readme if on unsupported environment" do
        io = StringIO.new
        opener = LearnOpen::Opener.new("readme", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: {},
                                       system_adapter: system_adapter,
                                       io: io,
                                       platform: "linux")
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
It looks like this lesson is a Readme. Please open it in your browser.
EOF
      end

      it "writes to custom_commands_log on IDE" do
        environment = {"CREATED_USER" => "bobby", "IDE_CONTAINER" => "true"}
        io = StringIO.new
        home_dir = create_linux_home_dir("bobby")
        opener = LearnOpen::Opener.new("readme", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: environment,
                                       system_adapter: system_adapter,
                                       io: io)
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        custom_commands_log = File.read("#{home_dir}/.custom_commands.log")
        expect(custom_commands_log).to eq("{\"command\": \"browser_open\", \"url\": \"https://learn.co/lessons/31322\"}\n")
      end
      context "on a mac" do
        it "opens safari by default" do
          io = StringIO.new
          expect(system_adapter)
            .to receive(:run_command)
            .with("open -a Safari https://learn.co/lessons/31322")

          opener = LearnOpen::Opener.new("readme", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {},
                                         system_adapter: system_adapter,
                                         io: io,
                                         platform: "darwin")
          opener.run

          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        end

        it "opens chrome if it exists" do
          FileUtils.mkdir_p("/Applications")
          FileUtils.touch('/Applications/Google Chrome.app')
          io = StringIO.new
          expect(system_adapter)
            .to receive(:run_command)
            .with("open -a 'Google Chrome' https://learn.co/lessons/31322")


          opener = LearnOpen::Opener.new("readme", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {},
                                         system_adapter: system_adapter,
                                         io: io,
                                         platform: "darwin")
          opener.run

          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Opening readme...
EOF
        end
      end
    end
    context "iOS labs" do
      it "fails to open unless on a mac" do
        io = StringIO.new
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/ios_lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")

        opener = LearnOpen::Opener.new("ios_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       io: io,
                                       platform: "linux")
        opener.run

        io.rewind
        expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
You need to be on a Mac to work on iOS lessons.
Done.
EOF
      end

      it "opens xcodeproj if on a mac and it exists" do
        io = StringIO.new
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/ios_lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:run_command)
          .with("cd /home/bobby/Development/code/ios_lab && open *.xcodeproj")


        opener = LearnOpen::Opener.new("ios_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       io: io,
                                       platform: "darwin")
        opener.run

      end
      it "opens xcworkspace if on a mac and it exists" do
        io = StringIO.new
        expect(system_adapter)
          .to receive(:change_context_directory)
          .with("/home/bobby/Development/code/ios_with_workspace_lab")
        expect(system_adapter)
          .to receive(:open_login_shell)
          .with("/usr/local/bin/fish")
        expect(system_adapter)
          .to receive(:run_command)
          .with("cd /home/bobby/Development/code/ios_with_workspace_lab && open *.xcworkspace")


        opener = LearnOpen::Opener.new("ios_with_workspace_lab", "atom", false,
                                       learn_client_class: learn_client_class,
                                       git_adapter: git_adapter,
                                       environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                       system_adapter: system_adapter,
                                       io: io,
                                       platform: "darwin")
        opener.run

      end
    end
    context "Lab" do
      context "installing dependencies" do
        it "runs bundle install if lab is a ruby lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: ["atom", path: "."],
              open_login_shell: ["/usr/local/bin/fish"],
              change_context_directory: ["/home/bobby/Development/code/rails-dynamic-request-lab-cb-000"],
            )

          expect(system_adapter)
            .to receive(:run_command)
            .with("bundle install")
          opener = LearnOpen::Opener.new("ruby_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         io: spy)
          opener.run
        end

        it "outputs correctly for ruby lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("ruby_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         io: io)
          opener.run
          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Bundling...
Done.
EOF
        end

        it "runs pip install if lab is a python lab" do
          expect(system_adapter)
            .to receive(:open_editor)
            .with("atom", path: ".")

          expect(system_adapter)
            .to receive(:open_login_shell)
            .with("/usr/local/bin/fish")

          expect(system_adapter)
            .to receive(:change_context_directory)
            .with("/home/bobby/Development/code/python_lab")

          expect(system_adapter)
            .to receive(:run_command)
            .with("python -m pip install -r requirements.txt")
          opener = LearnOpen::Opener.new("python_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         io: spy)
          opener.run
        end
        it "outputs correctly for python lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("python_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
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
        it "runs npm install if lab is a node lab" do
          expect(system_adapter)
            .to receive(:open_editor)
            .with("atom", path: ".")

          expect(system_adapter)
            .to receive(:open_login_shell)
            .with("/usr/local/bin/fish")

          expect(system_adapter)
            .to receive(:change_context_directory)
            .with("/home/bobby/Development/code/node_lab")

          expect(system_adapter)
            .to receive(:run_command)
            .with("npm install")
          opener = LearnOpen::Opener.new("node_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         io: spy)
          opener.run
        end
        it "outputs correctly for node lab" do
          allow(system_adapter)
            .to receive_messages(
              open_editor: :noop,
              open_login_shell: :noop,
              change_context_directory: :noop,
              run_command: :noop,
            )

          io = StringIO.new
          opener = LearnOpen::Opener.new("node_lab", "atom", false,
                                         learn_client_class: learn_client_class,
                                         git_adapter: git_adapter,
                                         environment_vars: {"SHELL" => "/usr/local/bin/fish"},
                                         system_adapter: system_adapter,
                                         io: io)
          opener.run
          io.rewind
          expect(io.read).to eq(<<-EOF)
Looking for lesson...
Forking lesson...
Cloning lesson...
Opening lesson...
Installing npm dependencies...
Done.
EOF
        end
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

