require 'spec_helper'
require 'fakefs/spec_helpers'

describe LearnOpen::Environments::IDEEnvironment do
  include FakeFS::SpecHelpers
  subject { LearnOpen::Environments::IDEEnvironment }

  let(:io) { instance_double(LearnOpen::Adapters::IOAdapter) }

  context "Invalid environment" do
    before do
      @home_dir = create_linux_home_dir("bobby")

      expect(io)
        .to receive(:puts)
        .with("Opening new window")
    end

    let(:lesson) { double(name: "a-different-lesson") }
    let(:env_vars) {{ "LAB_NAME" => "correct_lab", "CREATED_USER" => "bobby" }}
    let(:environment) { subject.new({ io: io, environment_vars: env_vars, logger: spy }) }

    it "opens correct readme" do
      environment.open_readme(lesson)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end

    it "opens correct lab" do
      environment.open_lab(lesson, double, double)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end

    it "opens correct jupyter lab" do
      environment.open_jupyter_lab(lesson, double, double)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"open_lab","lab_name":"a-different-lesson"}\n})
    end
  end

  context "valid environments" do
    before do
      @home_dir = create_linux_home_dir("bobby")
    end

    let(:lesson) { double(name: "valid_lab", later_lesson: false, to_url: "valid-lesson-url") }
    let(:env_vars) {{ "LAB_NAME" => "valid_lab", "CREATED_USER" => "bobby" }}
    let(:environment) { subject.new({ io: io, environment_vars: env_vars, logger: spy }) }

    it "opens the readme in the browser" do
      expect(io).to receive(:puts).with("Opening readme...")
      environment.open_readme(lesson)
      custom_commands_log = File.read("#{@home_dir}/.custom_commands.log")
      expect(custom_commands_log).to eq(%Q{{"command":"browser_open","url":"valid-lesson-url"}\n})
    end
    it "opens the lab" do
      expect(io).to receive(:puts).with("Opening readme...")
      environment.open_lab(lesson, double, double)
    end
  end
end
