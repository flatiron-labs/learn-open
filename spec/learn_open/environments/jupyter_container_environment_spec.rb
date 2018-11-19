require 'spec_helper'
require 'fakefs/spec_helpers'

describe LearnOpen::Environments::JupyterContainerEnvironment do
  include FakeFS::SpecHelpers
  subject { LearnOpen::Environments::JupyterContainerEnvironment }

  let(:io) { instance_double(LearnOpen::Adapters::IOAdapter) }

  context "valid environments" do
    before do
      @home_dir = create_linux_home_dir("bobby")
    end

    let(:lesson) do
      double(
        name: "valid_lab",
        later_lesson: false,
        to_url: "valid-lesson-url",
        to_path: @home_dir,
        git_server: "github.com",
        repo_path: "/org/lesson",
        use_student_fork: true
      )
    end

    let(:deployed_source_lesson) do
      double(
        name: "valid_lab",
        later_lesson: false,
        to_url: "valid-lesson-url",
        to_path: @home_dir,
        git_server: "github.com",
        repo_path: "/org/lesson",
        use_student_fork: false
      )
    end

    let(:env_vars) {{ "LAB_NAME" => "valid_lab", "CREATED_USER" => "bobby", "SHELL" => "/usr/local/fish"}}
    let(:git_adapter) { double }
    let(:system_adapter) { double }
    let(:git_ssh_connector) { double(call: true) }
    let(:environment) do
      subject.new({
          io: io,
          environment_vars: env_vars,
          logger: spy,
          git_adapter: git_adapter,
          system_adapter: system_adapter,
          git_ssh_connector: git_ssh_connector
        })
    end

    it "does note lab using deployed repo as source" do
      location = double
      editor = "vim"

      expect(io).to receive(:puts).with("Cloning lesson...")
      expect(io).to receive(:puts).with("Opening lesson...")
      expect(io).to receive(:puts).with("Done.")
      expect(git_adapter)
        .to receive(:clone)
        .with("git@github.com:/org/lesson.git", "valid_lab", {:path=> location})
      expect(system_adapter)
        .to receive(:change_context_directory)
        .with("/home/bobby")
      expect(system_adapter)
        .to receive(:open_editor)
        .with("vim", {:path=>"."})
      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/fish")

      environment.open_jupyter_lab(deployed_source_lesson, location, editor)
    end
    it "opens the lab" do
      location = double
      editor = "vim"

      expect(io).to receive(:puts).with("Forking lesson...")
      expect(io).to receive(:puts).with("Cloning lesson...")
      expect(io).to receive(:puts).with("Opening lesson...")
      expect(io).to receive(:puts).with("Done.")
      expect(git_adapter)
        .to receive(:clone)
        .with("git@github.com:/org/lesson.git", "valid_lab", {:path=> location})
      expect(system_adapter)
        .to receive(:change_context_directory)
        .with("/home/bobby")
      expect(system_adapter)
        .to receive(:open_editor)
        .with("vim", {:path=>"."})
      expect(system_adapter)
        .to receive(:spawn)
        .with("restore-lab", {:block=>true})
      expect(system_adapter)
        .to receive(:watch_dir)
        .with("/home/bobby", "backup-lab")
      expect(system_adapter)
        .to receive(:open_login_shell)
        .with("/usr/local/fish")

      environment.open_jupyter_lab(lesson, location, editor)
    end
  end
end
